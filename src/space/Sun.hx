package space;

import h3d.prim.*;
import h3d.scene.pbr.DirLight;
import h3d.scene.pbr.PointLight;
import h3d.scene.Mesh;

/*
		var sunPos = new h3d.Vector( 10,  4,  8);   // wherever you want

		// visible ball (un-lit, emissive)
		var sunMesh = new Mesh(new h3d.prim.Sphere(24, 24, 1), scene);
		sunMesh.setPosition(sunPos.x, sunPos.y, sunPos.z);
		sunMesh.scale(1.8);

		sunMesh.material = Material.create();
		sunMesh.material.mainPass.setCustom("unlit", 1); // don’t react to lights
		sunMesh.material.color.set(1, 1, 0.75);          // yellowish

		// actual light
		var sunLight = new PointLight(scene);
		sunLight.setPosition(sunPos.x, sunPos.y, sunPos.z);
		sunLight.radius = 100;          // how far the light reaches
		sunLight.power  = 5000;         // brightness
		sunLight.color.set(1, 1, 0.9);

*/


class Sun extends h3d.scene.Object {

    public function new(parent: h3d.scene.Object) {
        super(parent);

        var sunPos = new h3d.Vector(10, 10, 10);  // Keep far for simulation scale

        // Visible ball (unlit, bright emissive-like via high color values for HDR brightness)
        var spherePrim = new Sphere(1, 32, 32);
        spherePrim.addNormals(); // Required for lighting
        spherePrim.addUVs(); // Optional, if using textures
        var sunMesh = new Mesh(spherePrim, this);  // Increase segments for smoother appearance (less "cloudy")
        sunMesh.scale(3);  // Slightly larger for better visibility at distance; adjust as needed

        sunMesh.material = h3d.mat.Material.create();
        sunMesh.material.mainPass.enableLights = false;  // Don’t react to lights
        sunMesh.material.color.set(50, 50, 37.5);  // Much higher values (>1) for bright, glowing appearance in PBR/HDR

        // Actual light: Use DirLight for distant sun (parallel rays, no falloff)
        var sunDir = sunPos.clone();
        sunDir.normalize();
        sunDir.scale(-1);
        var sunLight = new DirLight(sunDir, parent);  // Direction points toward origin (negative for light rays from sun to scene)
        sunLight.power = 5;  // Lower than point light; adjust for brightness (e.g., 2-10)
        sunLight.color.set(1, 1, 0.9);

        this.setPosition(sunPos.x, sunPos.y, sunPos.z);
    }
    
}