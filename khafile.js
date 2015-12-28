var project = new Project('GraphicsKha');

project.addAssets('Assets/**');
project.addSources('Sources');
project.addShaders('Sources/Shaders/**');

return project;
