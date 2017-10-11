// Starting with Gmsh 3.0, models can also be built using constructive solid
// geometry. Instead of the built-in geometry kernel, you need to use the
// OpenCASCADE kernel:

SetFactory("OpenCASCADE"); //Built-in or OpenCASCADE

/* Geometry data */
dr = 0.1;	// disk radius
dt = 0.01; // disk thickness
mh = 0.12; // magnet height
mw = 0.02; // magnet width
ml = 0.08; // magnet length
mt = 0.02; // magnet thickness
mg = 0.015; // magnet gap

ldisc = dt;
LayerDisk[] = {10,2,10};
HLayerDisk[] = {0.2,0.8,1}; // 0 < h1 < h2 < h3 = 1

dP0[]+=newp ; Point(dP0[0])  = {dr, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[1])  = {0, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[2])  = {-dr, 0, 0 , ldisc};

/* Create a disk */
dC1 = newreg; Circle(dC1) = {0,0,0,dr};
dL1 = newreg;  Line Loop(dL1) = {dC1}; 
dS1 = news; Plane Surface(dS1) = {dL1};
// extrude layers
DiskExtrude[] = Extrude {0,0,dt} {Surface{dS1}; Layers{ LayerDisk[],HLayerDisk[] }; Recombine;};

Physical Volume("Disk") = DiskExtrude[1];

/* Create a magnet */
// mouth part
dV1 = newreg; 
//Box(dV1) = {2,2,2, 1,1,1}; 
Box(dV1) = {-mt/2,dr-ml/2,(mg+dt)/2, mt,mw,(mh-mg)/2};
MirdV1[] = Translate {0, 0, -(mh+mg)/2} { Duplicata{ Volume{dV1}; } };
// horizontal part
dV2 = newreg;  
Box(dV2) = {-mt/2,dr-ml/2+mw,(mg+dt)/2+(mh-mg)/2-mw, mt,ml-mw,mw};
MirdV2[] = Translate {0, 0, -(mh-mw)} { Duplicata{ Volume{dV2}; } };
// base part
dV3 = newreg;
Box(dV3) = {-mt/2,dr+ml/2-mw,dt/2, mt,mw,(mh-2*mw)/2};
MirdV3[] = Translate {0, 0, -(mh-2*mw)/2} { Duplicata{ Volume{dV3}; } };

// Union all blocks
dV4 = newreg;
BooleanUnion(dV4) = { Volume{dV1,dV2,dV3}; Delete; }{ Volume{MirdV1,MirdV2,MirdV3}; Delete; };

Physical Volume("Magnet") = dV4;

/* Create air */

// Create infinity sphere
dV5 = newreg;
Sphere(dV5) = {0,0,0,2*dr};


// Create the copy of the disk
tmpd[] = Translate {0,0,0} { Duplicata{ Volume{ DiskExtrude[1] }; } };

// Create the copy of the magnet
tmpm[] = Translate {0,0,0} { Duplicata{ Volume{ dV4 }; } };

// Create the air around
dV6 = newreg;
BooleanDifference(dV6) = { Volume{dV5}; }{  Volume{ tmpd[0],tmpm[0] }; Delete; };
//BooleanDifference(dV6) = { Volume{dV5}; }{ Volume{DiskExtrude[1]};  };

Physical Volume("Air") = dV6;

/* Adjust mesh size */
Characteristic Length{PointsOf{Volume{dV4};}} = mw/2; //magnet
Characteristic Length{PointsOf{Volume{dV5};}} = mh; //adjust mesh size of the air

//Printf("New volume '%g' and '%g'", tmp[0], DiskExtrude[1]);

/* Color mesh */
Color Blue{ Volume{ dV6 }; } // Air
Color Yellow{ Volume{ DiskExtrude[1] }; } // Disk
Color Red{ Volume{ dV4 }; } // Magnet



