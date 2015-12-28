var project = new Project('BasicKha');

project.addAssets('Assets/**');
project.addSources('Sources');
project.addShaders('Sources/Shaders/**');

return project;
