package space;

import h3d.prim.*;
import h3d.scene.pbr.DirLight;
import h3d.scene.pbr.PointLight;
import h3d.scene.Mesh;

/*
	var sunPos = new h3d.Vector( 10,  4,  8);   
			var sunMesh = new Mesh(new h3d.prim.Sphere(24, 24, 1), scene);
	sunMesh.setPosition(sunPos.x, sunPos.y, sunPos.z);
	sunMesh.scale(1.8);

	sunMesh.material = Material.create();
	sunMesh.material.mainPass.setCustom("unlit", 1); 		sunMesh.material.color.set(1, 1, 0.75);          
			var sunLight = new PointLight(scene);
	sunLight.setPosition(sunPos.x, sunPos.y, sunPos.z);
	sunLight.radius = 100;          		sunLight.power  = 5000;         		sunLight.color.set(1, 1, 0.9);

 */
class Sun extends h3d.scene.Object {
	public function new(parent:h3d.scene.Object) {
		super(parent);

		var sunPos = new h3d.Vector(10, 10, 10);
		var spherePrim = new Sphere(1, 32, 32);
		spherePrim.addNormals();
		spherePrim.addUVs();
		var sunMesh = new Mesh(spherePrim, this);
		sunMesh.scale(3);
		sunMesh.material = h3d.mat.Material.create();
		sunMesh.material.mainPass.enableLights = false;
		sunMesh.material.color.set(50, 50, 37.5);
		var sunDir = sunPos.clone();
		sunDir.normalize();
		sunDir.scale(-1);
		var sunLight = new DirLight(sunDir, parent);
		sunLight.power = 5;
		sunLight.color.set(1, 1, 0.9);

		this.setPosition(sunPos.x, sunPos.y, sunPos.z);
	}
}
