module systems.graphics;

import std;

import bindbc.sdl;

import inmath.linalg;
import glamour.shader;
import glamour.texture;

import onehundred;


class Graphics : System!GraphicSource
{
  this(SDL_Renderer* sdlRenderer, Camera camera, Texture2D[string] textures)
  {
    this.shaders["coloredtexture"] = new Shader("shaders/coloredtexture.shader");
    this.textures = textures;
    this.camera = camera;
    this.sdlRenderer = sdlRenderer;
  }

  override void close()
  {
    blobs.byValue.each!(blob => blob.texture.remove());
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("graphicsource");
  }
  
  GraphicSource makeComponent(Entity entity)
  {
    auto source = entity.get!string("graphicsource");

    assert(source != "text", "Graphicsource text no longer supported");

    Tuple!(Texture2D, int)[] animation;
    if (source !in textures)
    {
      // these sources should have been preloaded in the textures from the constructor
      assert(source != "polygon");
      if (source.endsWith(".gif"))
      {
          animation = Texture2D.from_gif(sdlRenderer, source);
          animation.each!((index, frameAndDelay) => textures[source ~ "_" ~ index.to!string] = frameAndDelay[0]);
      }
      textures[source] = Texture2D.from_image(sdlRenderer, source);
    }
    if (source !in blobs)
    {
      if (source.endsWith(".gif"))
      {
        blobs[source] = new GraphicsBlob(animation[0][0]); // use first frame as default texture
        blobs[source].setFramesAndDelays(animation);
      }
      else
      {
        blobs[source] = new GraphicsBlob(textures[source]);
      }
    }

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
    {
      data = new GraphicsData(baseSquare.dup.map!(vertex => vertex * mat3.zRotation(PI/2)).array, 
                              baseTexCoordsSquare.dup);
    }
    
    auto position = entity.get!vec3("position");
    auto angle = entity.get!double("angle", entity.get!float("angle"));
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double

    return new GraphicSource(source, position, angle, size, data);
  }

  void updateValues(bool paused)
  {
    blobs.byValue.each!(blob => blob.reset());
    foreach (component; components)
      blobs[component.sourceName].addData(component.transformedData);
    foreach (name, blob; blobs)
      blob.render(shaders["coloredtexture"], name == "polygon", camera.transform);
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
  GraphicsBlob[string] blobs;

  Camera camera;

  SDL_Renderer* sdlRenderer;
}
