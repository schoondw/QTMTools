# QTMTools

Matlab Toolbox for handling mocap data from QTM. QTMTools supports reading of Matlab exported QTM files.

Mocap data includes:
- 3D trajectory data
- 6DOF rigid body data
- skeleton data

Examples of use.

Read QTM mat file:
`mc = mocapdata('myfile.mat')`

Indexing:
Retrieve trajectory with label "RightElbow" using the label as index (see labeladmin2 for more info).
`relb = mc.Trajectories("RightElbow");`

Transform segment from global to parent:
```
Hips_global = mc.Skeletons(1).Segments('Hips'); % Copy Hips segment (not necessary, but just for clarity)
Spine_local = mc.Skeletons(1).Segments('Spine').global2local(Hips_global);
```

For more example scripts, see the folder "Examples".

Note: Other types of data, for example analog data, are currently not implemented.

## Install
Add the folders including subfolders to the Matlab path, for example using *addpath(genpath(...))*.

## Mocap data classes

### mocapdata
Mocap data class.
Contains mocap data from QTM files:
- Trajectories (trajectory array)
- RigidBodies (rigidbody array)
- Skeletons (skeleton array)

### trajectory
Trajectory data class.
Superclasses: labeladmin2
Contains trajectory data:
- Position (vec3d array)
- Residual (double array)
- Type (double array)
- Label (string, from labeladmin2)

### rigidbody
Rigid body data class.
Superclasses: pose6d, labeladmin2
Contains rigid body data:
- Parent (string)
- Position (vec3d array)
- Rotation (quaternion array)
- Label (string, from labeladmin2)

Methods:
- global2local: transform rigid body to reference coordinate sytem. Overloading pose6d:local2global.

### skeleton
Skeleton data class.
Superclasses: labeladmin2
Contains skeleton data:
- Segments (segment array)
- Label (string, from labeladmin2)

### segment
Segment data class.
Super clases: pose6d, labeladmin2
Contains segment data:
- Parent (string)
- Position (vec3d array)
- Rotation (quaternion array)
- Label (string, from labeladmin2)

Methods:
- global2local: transform segment to reference coordinate system. Overloading pose6d:local2global.

## Data representation classes

### pose6d
Represention of 6DOF data.
Properties:
- Position (vec3d array)
- Rotation (quaternion array)

Methods:
- global2local: transform pose6d object to reference coordinate system. Reference system is another pose6d based object of compatible size.
- eulerAngles: retrieve Euler angles based on specified rotation order.
- unitVectors: retrieve unit vectors of local coordinate system.

### vec3d
Representation of 3D vector.

Properties: x, y, z

Methods: overloading of relevant basic mathematical operations for vector calculations, e.g., addition, multiplication. Posible to use operators, e.g., p1 + p2. Most methods support binary singleton expansion.

### quaternion
Representation of rotation. 

Adapted from:
Mark Tincknell (2020). quaternion (https://www.mathworks.com/matlabcentral/fileexchange/33341-quaternion), MATLAB Central File Exchange.

Properties: w, x, y, z

Methods: overloading of relevant basic mathematical operations for quaternion calculations, e.g., addition, multiplication. Posible to use operators, e.g., q1 + q2. Most methods support binary singleton expansion.

## Helper classes

### labeladmin2
Superclass for labeling and subreferencing.

Supports subreferencing using labels, for example: `mc.Trajectories('RightElbow')` returns the trajectory with label "RightElbow". Label indices can be specified as:
- char array, e.g., `'RightElbow'`
- cell array of char, e.g., `{'RightElbow', 'LeftElbow'}`
- string, e.g., `"RightElbow"`
- string array, e.g., `["RightElbow", "LeftElbow"]`

Properties:
- Label

Methods:
- LabelIndex: retrieve index to object array.
- LabelCheck: check if labels are present.
- LabelList: get list of labels from object array.

## Utilities

Helper functions used by the classes.
