A example of a Kha graphics4 use, also loads a image and use the keyboard and mouse as per BasicKha.
Has PolyK included also MIT

view here:

<iframe src="https://cdn.rawgit.com/Justinfront/GraphicsKha/master/build/html5/graphicsKha_.html" frameborder="0" scrolling="0" width="1280px" height="720px"></iframe>

References

http://luboslenco.com/kha3d/ see example 6.

https://github.com/RafaelOliveira/BasicKha

polyk.ivank.net

see also TwoLines previous experiments

### How to use

**Kha from git**  
Install [nodejs]  
On the command line, run:
```
git clone https://github.com/Justinfront/GraphicsKha
cd GraphicsKha  
git submodule update --init --recursive
node Kha/make html5
```
Then open the FlashDevelop project for html5 in the build folder.

To update Kha, you can run:  
```
git submodule foreach --recursive git pull origin master
```

[nodejs]:https://nodejs.org
