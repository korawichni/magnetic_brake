// Starting with Gmsh 3.0, models can also be built using constructive solid
// geometry. Instead of the built-in geometry kernel, you need to use the
// OpenCASCADE kernel:

SetFactory("OpenCASCADE"); //Built-in or OpenCASCADE
General.ExpertMode = 1; // Disable the message

/* Geometry data */
dr = 0.1;	// disk radius
dt = 0.01; // disk thickness
mh = 0.12; // magnet height
mw = 0.02; // magnet width
ml = 0.08; // magnet length
mt = 0.02; // magnet thickness
mg = 0.015; // magnet gap

ldisc = dt;
LayerDisk[] = {4,2,4};
HLayerDisk[] = {0.4,0.6,1}; // 0 < h1 < h2 < h3 = 1

dP0[]+=newp ; Point(dP0[0])  = {dr, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[1])  = {0, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[2])  = {-dr, 0, 0 , ldisc};

/* Create a disk */
dC1 = newreg; Circle(dC1) = {0,0,0,dr};
dL1 = newreg;  Line Loop(dL1) = {dC1}; 
dS1 = news; Plane Surface(dS1) = {dL1};
// extrude layers
DiskExtrude[] = Extrude {0,0,dt} {Surface{dS1}; Layers{ LayerDisk[],HLayerDisk[] }; };

Physical Volume("Disk") = DiskExtrude[1];

/* Create a magnet and yolk*/
// yoke mouth
dV1 = newreg; 
//Box(dV1) = {2,2,2, 1,1,1}; 
Box(dV1) = {-mt/2,dr-ml/2,(mg+dt)/2, mt,mw,(mh-mg)/2};
MirdV1[] = Translate {0, 0, -(mh+mg)/2} { Duplicata{ Volume{dV1}; } };
// horizontal part of yoke
dV2 = newreg;  
Box(dV2) = {-mt/2,dr-ml/2+mw,(mg+dt)/2+(mh-mg)/2-mw, mt,ml-mw,mw};
MirdV2[] = Translate {0, 0, -(mh-mw)} { Duplicata{ Volume{dV2}; } };
// magnet part
dV3 = newreg;
Box(dV3) = {-mt/2,dr+ml/2-mw,dt/2, mt,mw,(mh-2*mw)/2};
MirdV3[] = Translate {0, 0, -(mh-2*mw)/2} { Duplicata{ Volume{dV3}; } };

// Union all blocks for yoke
//dVyoke = newreg;
//BooleanUnion(dVyoke) = { Volume{dV1,dV2}; Delete; }{ Volume{MirdV1,MirdV2}; Delete; };
yoke() = BooleanFragments{ Volume{dV1,dV2}; Delete; }{ Volume{MirdV1,MirdV2}; Delete; };
Physical Volume("Yoke") = yoke();

// Union all blocks for magnet
//dVmagnet = newreg;
//BooleanUnion(dVmagnet) = { Volume{dV3}; Delete; }{ Volume{MirdV3}; Delete; };
magnet() = BooleanFragments{ Volume{dV3}; Delete; }{ Volume{MirdV3}; Delete; };
Physical Volume("Magnet") = magnet(); //dVmagnet;
//dVstruct = newreg;
//BooleanUnion(dVstruct) = { Volume{yoke()}; }{ Volume{dVmagnet}; };

// Get rid of overlapped surface ??
tmp() = BooleanFragments{ Volume{magnet()}; Delete; }{ Volume{yoke()}; Delete;};

/* Create air */

// Create infinity sphere
dV5 = newreg;
Sphere(dV5) = {0,0,0,2*dr};
Characteristic Length{PointsOf{Volume{dV5};}} = mh/3; //adjust mesh size of the sphere

// Create the copy of the disk
//tmpd[] = Translate {0,0,0} { Duplicata{ Volume{ DiskExtrude[1] }; } };

// Create the copy of the magnet
//tmpm[] = Translate {0,0,0} { Duplicata{ Volume{ dV4 }; } };

// Create the air around
dV6 = newreg;
//BooleanDifference(dV6) = { Volume{dV5}; }{  Volume{ tmpd[0],tmpm[0] }; Delete; };
BooleanDifference(dV6) = { Volume{dV5}; Delete; }{ Volume{DiskExtrude[1],yoke(),magnet()};  };

Physical Volume("Air") = dV6;

/* Adjust mesh size */
// Characteristic Length{PointsOf{Volume{dV6};}} = mh; //adjust mesh size of the air
Characteristic Length{PointsOf{Volume{DiskExtrude[1]};}} = dt; //disk
//Characteristic Length{PointsOf{Volume{dVmagnet};}} = mw/2; //magnet
Characteristic Length{PointsOf{Volume{yoke()};}} = mw/2; //yoke

Printf("New volume '%g' and '%g'", magnet[1], DiskExtrude[1]);

/* Color mesh */
Recursive Color Blue{ Volume{ dV6 }; } // Air
Recursive Color Yellow{ Volume{ DiskExtrude[1] }; } // Disk
Recursive Color Red{ Volume{ magnet() }; } // Magnets
Recursive Color Grey{ Volume{ yoke() }; } // Magnets