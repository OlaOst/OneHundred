module systems.texthandler;

import std;

import inmath.linalg;
import glamour.shader;
import glamour.texture;

import onehundred;


class TextHandler : System!Text
{
  this(TextRenderer textRenderer, Camera worldCamera, Camera uiCamera, Texture2D textAtlas)
  {
    this.shaders["coloredtexture"] = new Shader("shaders/coloredtexture.shader");
    
    this.worldTextBlob = new GraphicsBlob(textAtlas);
    this.uiTextBlob = new GraphicsBlob(textAtlas);
    
    this.textRenderer = textRenderer;
    this.worldCamera = worldCamera;
    this.uiCamera = uiCamera;
  }

  override void close()
  {
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("text");
  }

  override void tweakEntity(ref Entity entity)
  {
    if ("text" in entity.values)
      entity["text"] = entity["text"].replace("\\n", "\n");
  }
  
  Text makeComponent(Entity entity)
  {
    auto text = entity.get!string("text");
    auto positionRelativeTo = entity.get!string("positionRelativeTo");

    Camera cameraForComponent = worldCamera;
    if (positionRelativeTo == "screen")
      cameraForComponent = uiCamera;

    auto data = textRenderer.getGraphicsData(text, entity.get!vec4("color"));

    auto position = entity.get!vec3("position");
    auto angle = entity.get!double("angle", entity.get!float("angle"));
    assert(entity.has("size"));
    auto size = entity.get!double("size", entity.get!float("size")); // TODO: should only be double

    return new Text(text, positionRelativeTo, position, angle, size, data);
  }

  void updateValues(bool paused)
  {
    worldTextBlob.reset();
    uiTextBlob.reset();

    auto worldComponents = components.filter!(component => component.positionRelativeTo != "screen");
    auto uiComponents = components.filter!(component => component.positionRelativeTo == "screen");

    worldComponents.each!(component => worldTextBlob.addData(component.transformedData));
    uiComponents.each!(component => uiTextBlob.addData(component.transformedData));
    
    worldTextBlob.render(shaders["coloredtexture"], false, worldCamera.transform);
    uiTextBlob.render(shaders["coloredtexture"], false, uiCamera.transform);
  }

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle", entity.get!float("angle"));
      components[index].size = entity.get!double("size", entity.get!float("size"));

      components[index].data = textRenderer.getGraphicsData(entity.get!string("text"), 
                                                            entity.get!vec4("color"));
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
  GraphicsBlob worldTextBlob;
  GraphicsBlob uiTextBlob;
  
  TextRenderer textRenderer;
  Camera worldCamera;
  Camera uiCamera;
}
