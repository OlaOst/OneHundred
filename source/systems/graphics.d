module systems.graphics;

import std;

import bindbc.sdl;

import inmath.linalg;
import glamour.shader;
import glamour.texture;

import onehundred;


class Graphics : System!GraphicSource
{
  this(SDL_Renderer* sdlRenderer, Camera worldCamera, Camera uiCamera, Texture2D[string] textures)
  {
    this.shaders["coloredtexture"] = new Shader("shaders/coloredtexture.shader");
    this.textures = textures;
    this.worldCamera = worldCamera;
    this.uiCamera = uiCamera;
    this.sdlRenderer = sdlRenderer;
  }

  override void close()
  {
    worldBlobs.byValue.each!(blob => blob.texture.remove());
    uiBlobs.byValue.each!(blob => blob.texture.remove());
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("graphicsource");
  }
  
  GraphicSource makeComponent(Entity entity)
  {
    auto source = entity.get!string("graphicsource");
    auto positionRelativeTo = entity.get!string("positionRelativeTo");

    assert(source != "text", "Graphicsource text no longer supported");

    Camera cameraForComponent = worldCamera;
    if (positionRelativeTo == "screen")
      cameraForComponent = uiCamera;

    if (source !in textures)
    {
      // these sources should have been preloaded in the textures from the constructor
      assert(source != "polygon");
      textures[source] = Texture2D.from_image(sdlRenderer, source);
    }
    if (cameraForComponent == worldCamera)
      worldBlobs[source] = new GraphicsBlob(textures[source]);
    if (cameraForComponent == uiCamera)
      uiBlobs[source] = new GraphicsBlob(textures[source]);

    GraphicsData data;
    if (source == "polygon")
    {
      if (entity.has("polygon.colors"))
        data = new GraphicsData(entity.get!(vec3[])("polygon.vertices"), 
                                entity.get!(vec4[])("polygon.colors"));
      else
        data = new GraphicsData(entity.get!(vec3[])("polygon.vertices"), 
                                entity.get!vec4("color"));
    }
    else
      data = new GraphicsData(baseSquare.dup.map!(vertex => vertex * mat3.zRotation(PI/2)).array, 
                              baseTexCoordsSquare.dup);

    auto position = entity.get!vec3("position");

    auto angle = entity.get!double("angle", entity.get!float("angle"));
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double

    return new GraphicSource(source, positionRelativeTo, position, angle, size, data);
  }

  void updateValues(bool paused)
  {
    worldBlobs.byValue.each!(blob => blob.reset());
    uiBlobs.byValue.each!(blob => blob.reset());

    auto worldComponents = components.filter!(component => component.positionRelativeTo != "screen");
    auto uiComponents = components.filter!(component => component.positionRelativeTo == "screen");

    worldComponents.each!(component => worldBlobs[component.sourceName].addData(component.transformedData));
    uiComponents.each!(component => uiBlobs[component.sourceName].addData(component.transformedData));

    foreach (name, blob; worldBlobs)
      blob.render(shaders["coloredtexture"], name == "polygon", worldCamera.transform);
    foreach (name, blob; uiBlobs)
      blob.render(shaders["coloredtexture"], name == "polygon", uiCamera.transform);
  }

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle", entity.get!float("angle"));
      components[index].size = entity.get!double("size", entity.get!float("size"));
    }
  }

  void updateEntities()
  {
    // TODO: set aabb properly using position, angle and vertices
    foreach (index, entity; entityForIndex)
      entity["aabb"] = [components[index].aabb.min, components[index].aabb.max];
  }

  Shader[string] shaders;
  Texture2D[string] textures;
  GraphicsBlob[string] worldBlobs;
  GraphicsBlob[string] uiBlobs;

  Camera worldCamera;
  Camera uiCamera;

  SDL_Renderer* sdlRenderer;
}
