// Starting with Gmsh 3.0, models can also be built using constructive solid
// geometry. Instead of the built-in geometry kernel, you need to use the
// OpenCASCADE kernel:

SetFactory("OpenCASCADE"); //Built-in or OpenCASCADE



pr = 0.3e-3*1.5;
pr2 = 1e-3;
pr3 = 4e-3;
pax = 0.5e-3;
dr = 0.1;
dt = 0.01;
ldisc = dt;
LayerDisk[] = {10,2,10};
HLayerDisk[] = {0.2,0.8,1}; // 0 < h1 < h2 < h3 = 1


dP0[]+=newp ; Point(dP0[0])  = {dr, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[1])  = {0, 0, 0 , ldisc};
dP0[]+=newp ; Point(dP0[2])  = {-dr, 0, 0 , ldisc};


// create a disk
dC1 = newreg; Circle(dC1) = {0,0,0,dr};

dL1 = newreg;  Line Loop(dL1) = {dC1}; 
dS1 = news; Plane Surface(dS1) = {dL1};
// extrude layers
DiskExtrude[] = Extrude {0,0,dt} {
	Surface{dS1}; Layers{ LayerDisk[],HlayerDisk[] }; Recombine;
};

//dV1 = newreg;
//Sphere(dV1) = {0,0,0,dr*3};


/* dPo[]+=newp ; Point(dPo[0])  = {X1, Y2, 0 , pax};
dPo[]+=newp ; Point(dPo[1])  = {X2, Y2, 0 , pr2};
dPo[]+=newp ; Point(dPo[2])  = {X3, Y2, 0 , pr2};
dPo[]+=newp ; Point(dPo[3])  = {X4, Y2, 0 , pr2};

dPo[]+=newp ; Point(dPo[4])  = {X4, Y3, 0 , pr2};
dPo[]+=newp ; Point(dPo[5])  = {X4, Y4, 0 , pr};
dPo[]+=newp ; Point(dPo[6])  = {X4,  0, 0 , pr};

dPo[]+=newp ; Point(dPo[7])  = {X3,  0, 0 , pr};
dPo[]+=newp ; Point(dPo[8])  = {X3, Y4, 0 , pr};
dPo[]+=newp ; Point(dPo[9])  = {X3, Y3, 0 , pr}; */