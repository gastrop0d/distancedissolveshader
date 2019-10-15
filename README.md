# Distance Dissolve Shaders for Unity
## Purpose
These shaders allow for objects to gradually become invisible as they approach within a near-distance to the camera. This is useful in fixed camera angle settings such as top-down games in order to prevent world geometry from occluding the play space. The shader uses a procedural noise function to dissolve surfaces, creating a nice transition effect between opaque and transparent states.

![Dissolve Shader Example](https://moltenmetalgames.files.wordpress.com/2019/10/dissolve-1.gif)

## Usage
There are several versions of the shader, for use with different Unity renderers:
- **Standard** - For non-transparent props and characters
- **StandardCutout** - For props and characters with areas of total transparency
- **Terrain** - For use with Unity's terrain renderers. Both *FirstPass* and *AddPass* shaders are required.
- **ParticleBlend** - For use with alpha-blended particle renderers
- **ParticleAdd** - For use with add-blended particle renderers

Import the shaders into your project, create materials and assign the shaders to the materials accordingly. Once the shader has been assigned, many parameters are available for tweaking behaviour:

- **Near Clip Distance** - The distance at which a surface will be fully transparent.
- **Noise Amount** - Over what distance to blend between fully opaque and fully transparent states.
- **Noise Threshold** - The distance from the Near Clip Distance to begin introducing noise.
- **Noise Scale** - How visibly large the noise should be
- **Noise Offset** - Used to adjust the specific noise shapes being generated over surfaces
- **Screen Centre Threshold** - To what extent should a surface's proximity to the centre of the screen affect transparency

## Compatability
The shaders were created and tested within **Unity 2017.4**. They may not function as expected in other versions.
