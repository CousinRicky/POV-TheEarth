
// TheEarth.pov version 1.2
// ------------------------

// Sample scene that maps an image of the earth onto a sphere
// Created by Chris Bartlett 07.02.2005
// Updated 2007 by Chris Bartlett for inclusion in the POV-Ray Object Collection
// Version 1.1 updated 2023-12-07 by Richard Callwood III:
//   A #version is added.
//   The transfer to the sphere is changed from cylindrical to uv mapping.
//   The assumed_gamma is set, the finish ambients reduced accordingly, and the image maps gamma decoded.
//   The control variables can be set externally.
// Version 1.2 updated 2024-01-23 by Richard Callwood III:
//   The clouds are rotated with the rest of the planet.
// This file is licensed under the terms of the GNU-LGPL.
// Please visit https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html for the text of the GNU-LGPL.
// Source https://lib.povray.org/
// Typical render time 1 second
// Radius is 0.5 POV-Ray units
// Position is 0.5 POV-Ray units above the origin
// The images included in the download come from https://www.evl.uic.edu/pape/data/Earth/ where
// there are higher resolution images along with alternative data representations.
// They were created by Dave Pape, while a federal employee at NASA/GSFC and are copyright free.
// These images are in a cylindrical mapping.
#version max (3.5, min (3.8, version));
global_settings { assumed_gamma 1 }

camera {location  <4,2,-8> look_at <0,0.5,0> angle 10}
light_source {<-100, 10, -300> color rgb 1.5}

#ifndef (TheEarth_CloudsOn) #declare TheEarth_CloudsOn = yes; #end
#ifndef (TheEarth_Rotation)
  #if (clock_on)
    #declare TheEarth_Rotation = -y*clock*360;
  #else
    #declare TheEarth_Rotation = y*210;
  #end
#end
#ifndef (TheEarth_SourceImage)
  #declare TheEarth_SourceImage = "theearth_bigearth.jpg";       // 'True' colour representation - high resolution
  //#declare TheEarth_SourceImage = "theearth_topography.jpg";   // Colours indicate Heights and Depths
  //#declare TheEarth_SourceImage = "theearth_mapperwdb.jpg";    // World DataBase Country markings
#end

// Gamma adjustment added by R. Callwood.
// Gamma 2.2 is assumed for these pre-sRGB era images.
#macro TheEarth_Decode_Gamma (Image)
  #if (version < 3.7)
    #local TheEarth_fn_Map = function
    { pigment { image_map { jpeg Image interpolate 2 } }
    }
    average pigment_map
    { [ function { pow (TheEarth_fn_Map (x, y, z).red, 2.2) }
        color_map { [0 rgb 0] [1 red 3] }
      ]
      [ function { pow (TheEarth_fn_Map (x, y, z).green, 2.2) }
        color_map { [0 rgb 0] [1 green 3] }
      ]
      [ function { pow (TheEarth_fn_Map (x, y, z).blue, 2.2) }
        color_map { [0 rgb 0] [1 blue 3] }
      ]
    }
  #else
    image_map { jpeg Image gamma 2.2 interpolate 2 }
  #end
#end

// The Earth itself
#declare TheEarth = sphere {<0,0.5,0>,0.5
  texture {
    pigment {
      uv_mapping
      TheEarth_Decode_Gamma (TheEarth_SourceImage)
    }
    finish {ambient 0.01}
  }
}

// A crude cloud layer
#declare TheEarth_Clouds = sphere {<0,0.5,0>,0.501
  texture {
    pigment {
      spotted  turbulence 1 omega 0.6
      color_map {
        [0.0   color rgb 1]
        [0.25  color rgb 1]
        [0.55  color rgbt 1]
        [1.0   color rgbt 1]
      }
      scale <0.3,0.1,0.3>
    }
    finish {ambient 0.01}
    translate vrotate (0.1 * z, TheEarth_Rotation) // Vary the clouds a bit.
    rotate TheEarth_Rotation
  }
}

// Draw the objects
object {TheEarth rotate TheEarth_Rotation}
#if (TheEarth_CloudsOn)
   object {TheEarth_Clouds}
#end
