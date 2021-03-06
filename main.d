import std.stdio;

import Dgame.Window.all;
import Dgame.Graphics.all;
import Dgame.Audio.all;
import Dgame.System.all;

//pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict2\\lib\\DerelictGL.lib");
//pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict2\\lib\\DerelictUtil.lib");

pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict\\lib\\DerelictSDL2.lib");
pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict\\lib\\DerelictUtil.lib");
pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict\\lib\\DerelictGL3.lib");
pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict\\lib\\DerelictAL.lib");
pragma(lib, "D:\\D\\dmd2\\src\\ext\\derelict\\lib\\DerelictOGG.lib");

import Dgame.Core.core : getDgVersion;

pragma(msg, getDgVersion());

pragma(msg, Color.sizeof);
pragma(msg, Font.sizeof);
pragma(msg, Surface.sizeof);
pragma(msg, Pixel.sizeof);
pragma(msg, Vertex.sizeof);
pragma(msg, FloatRect.sizeof);
pragma(msg, Vector2f.sizeof);
pragma(msg, vec2f.sizeof);

void main() {
	const ushort width = 1024;
	const ushort height = 640;
	
	Window wnd = new Window(VideoMode(width, height), "Dgame Demo");
	wnd.setVerticalSync(Window.Sync.Disable);
	//wnd.setFpsLimit(15);
	wnd.setClearColor(Color.Green);
	
	{
		writeln("<>");
		Surface test = Surface("samples/img/wiki.png");
		Surface test2 = test;
		test2 = test;
		writeln("</>");
	}
	writeln("====");
	
	Sound[2] sound;
	//sound[0] = new Sound(new VorbisFile("samples/audio/orchestral.ogg"));
	//sound[1] = new Sound(new WaveFile("samples/audio/step.wav"));
	//sound[0] = new Sound("samples/audio/orchestral.ogg");
	//sound[1] = new Sound("samples/audio/step.wav");
	sound[0] = Sound.loadOnce("samples/audio/orchestral.ogg");
	sound[1] = Sound.loadOnce("samples/audio/step.wav");
	
	Color ccol = Color(0.7, 0.7, 0.7);
	writefln("Green Color: %d,%d,%d,%d", Color.Green.red, Color.Green.green, Color.Green.blue, Color.Green.alpha);
	
	Shape qs = Shape.make(Shape.Type.Quad, [
	                                        Vector2f(75, 75),
	                                        Vector2f(275, 75),
	                                        Vector2f(275, 275),
	                                        Vector2f(75, 275)]);
	//qs.setSmooth(Shape.SmoothTarget.Line, Shape.SmoothHint.Nicest);
	qs.enableFill(true);
	qs.setPixelColor(Color.Blue);
	//qs.setType(Shape.Type.Triangle);
	//	qs.rotate(-25);
	qs.setPosition(500, 300);
	
	Shape circle = Shape.makeCircle(25, Vector2f(180, 380));
	circle.setSmooth(Smooth.Target.Line);
	
	Shape many = Shape.make(Shape.Type.Quad, [
	                                          Vector2f(55, 55),
	                                          Vector2f(60, 55),
	                                          Vector2f(60, 60),
	                                          Vector2f(55, 60),
	                                          Vector2f(15, 15),
	                                          Vector2f(20, 15),
	                                          Vector2f(20, 20),
	                                          Vector2f(15, 20),
	                                          Vector2f(30, 30),
	                                          Vector2f(35, 30),
	                                          Vector2f(35, 35),
	                                          Vector2f(30, 35),
	                                          Vector2f(40, 40),
	                                          Vector2f(45, 40),
	                                          Vector2f(45, 45),
	                                          Vector2f(40, 45)]);
	many.enableFill(true);
	many.setPixelColor(Color.Red);
	
	Surface wiki = Surface("samples/img/wiki.png"); // <
	
	Color col = wiki.getColorAt(82, 33);
	writefln("color: at (%d:%d) is %d, %d, %d", 82, 33, col.red, col.green, col.blue);
	
	Surface copy = wiki.subSurface(ShortRect(0, 0, 50, 50)); // <
	copy.saveToFile("samples/img/wiki_sub.png");
	copy.setColorkey(Color(254, 200, 88));
	copy.setBlendMode(Surface.BlendMode.Add);
	copy.setAlphaMod(150);
	
	ShortRect dst = ShortRect(5, 5, 0, 0);
	wiki.blit(copy, null, &dst);
	wiki.saveToFile("samples/img/wiki_copy.png");
	
	Surface wiki2 = Surface("samples/img/wiki.png");
	///
	writefln("Bits: %d, Bytes: %d", wiki2.countBits(), wiki2.countBytes());
	
	Texture tex = new Texture();
	tex.loadFromMemory(wiki2.getPixels(), wiki2.width, wiki2.height, wiki2.countBits());
	Texture copy_tex = new Texture();
	copy_tex.loadFromMemory(copy.getPixels(), copy.width, copy.height, copy.countBits());
	
	ShortRect dst_copy = ShortRect(65, 25, copy.width, copy.height);
	
	Texture tex3 = tex.subTexture(dst_copy);
	writefln("\ttex3 -> w: %d, h: %d", tex3.width, tex3.height);
	Surface texToSrfc2 = Surface.make(tex3.getMemory(), tex3.width, tex3.height, tex3.getFormat().formatToBits());
	texToSrfc2.saveToFile("samples/img/wiki_sub.png");
	
	tex.copy(copy_tex, &dst_copy);
	writeln(" => ", tex);
	void* mem = tex.getMemory();
	writeln(" => ", mem);
	//
	Surface texToSrfc = Surface.make(tex.getMemory(), tex.width, tex.height, tex.getFormat().formatToBits());
	texToSrfc.saveToFile("samples/img/wiki_copy_tex.png");
	
	//	tex.setViewport(FloatRect(15, 15, 25, 25));
	
	Sprite wiki_sprite = new Sprite(tex);
	wiki_sprite.setPosition(50, 100);
	wiki_sprite.setTextureRect(ShortRect(15, 15, 25, 25));
	
	ushort[16 * 16] pixels = [0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0aab, 0x0789, 0x0bcc, 0x0eee, 0x09aa, 0x099a, 0x0ddd, 
	                          0x0fff, 0x0eee, 0x0899, 0x0fff, 0x0fff, 0x1fff, 0x0dde, 0x0dee, 
	                          0x0fff, 0xabbc, 0xf779, 0x8cdd, 0x3fff, 0x9bbc, 0xaaab, 0x6fff, 
	                          0x0fff, 0x3fff, 0xbaab, 0x0fff, 0x0fff, 0x6689, 0x6fff, 0x0dee, 
	                          0xe678, 0xf134, 0x8abb, 0xf235, 0xf678, 0xf013, 0xf568, 0xf001, 
	                          0xd889, 0x7abc, 0xf001, 0x0fff, 0x0fff, 0x0bcc, 0x9124, 0x5fff, 
	                          0xf124, 0xf356, 0x3eee, 0x0fff, 0x7bbc, 0xf124, 0x0789, 0x2fff, 
	                          0xf002, 0xd789, 0xf024, 0x0fff, 0x0fff, 0x0002, 0x0134, 0xd79a, 
	                          0x1fff, 0xf023, 0xf000, 0xf124, 0xc99a, 0xf024, 0x0567, 0x0fff, 
	                          0xf002, 0xe678, 0xf013, 0x0fff, 0x0ddd, 0x0fff, 0x0fff, 0xb689, 
	                          0x8abb, 0x0fff, 0x0fff, 0xf001, 0xf235, 0xf013, 0x0fff, 0xd789, 
	                          0xf002, 0x9899, 0xf001, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0xe789, 
	                          0xf023, 0xf000, 0xf001, 0xe456, 0x8bcc, 0xf013, 0xf002, 0xf012, 
	                          0x1767, 0x5aaa, 0xf013, 0xf001, 0xf000, 0x0fff, 0x7fff, 0xf124, 
	                          0x0fff, 0x089a, 0x0578, 0x0fff, 0x089a, 0x0013, 0x0245, 0x0eff, 
	                          0x0223, 0x0dde, 0x0135, 0x0789, 0x0ddd, 0xbbbc, 0xf346, 0x0467, 
	                          0x0fff, 0x4eee, 0x3ddd, 0x0edd, 0x0dee, 0x0fff, 0x0fff, 0x0dee, 
	                          0x0def, 0x08ab, 0x0fff, 0x7fff, 0xfabc, 0xf356, 0x0457, 0x0467, 
	                          0x0fff, 0x0bcd, 0x4bde, 0x9bcc, 0x8dee, 0x8eff, 0x8fff, 0x9fff, 
	                          0xadee, 0xeccd, 0xf689, 0xc357, 0x2356, 0x0356, 0x0467, 0x0467, 
	                          0x0fff, 0x0ccd, 0x0bdd, 0x0cdd, 0x0aaa, 0x2234, 0x4135, 0x4346, 
	                          0x5356, 0x2246, 0x0346, 0x0356, 0x0467, 0x0356, 0x0467, 0x0467, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
	                          0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff];
	{
		Surface icon = Surface.make(pixels.ptr, 16, 16, 32);
		wnd.setIcon(icon);
	}
	
	Spritesheet sp = new Spritesheet(new Image("samples/img/tileset.png"), ShortRect(119, 0, 16, 16));
	sp.setPosition(50, 200);
	
	Spritesheet sp2 = new Spritesheet(new Image("samples/img/tofte.png"), ShortRect(0, 0, 16, 16));
	sp2.setPosition(200, 50);
	
	Font font = Font("samples/font/arial.ttf", 14, Font.Mode.Blended);
	font.setHint(Font.Hint.Mono);
	Text text = new Text(font);
	text.setColor(Color.Blue);
	text.setPosition(25, 350);
	
	//	text("При употреблении алкоголя всегда надо закусывать.");
	
	//text.setBlendColor(Color.Red);
	text.setBlendMode(BlendMode.Multiply);
	//	text.rotate(20);
	
	Color[4] colors = [Color.Red, Color.Magenta, Color.White, Color.Blue];
	ubyte cidx = 0;
	
	TileMap tm = new TileMap("map2.tmx");
	
	Unit tof = new Unit(new Image("samples/img/tofte.png"),
	                    ShortRect(0, 0, 32, 32));
	tof.setPosition(400, 0);
	
	float[12] pos = [170, 170, 0,
	                 310, 170, 0,
	                 310, 310, 0,
	                 170, 310, 0];
	float[8] texels = [0, 0, 1, 0, 1, 1, 0, 1];
	
	Image img = new Image("samples/img/wiki.png");//, Texture.Format.RGB);
	
	VertexArray va = new VertexArray(img, Primitive.Type.Polygon);
	va.append(pos, texels);
	va.setColor(Color.Green.withTransparency(125));

	Image exploImg = new Image("samples/img/explosion.png");
	Spritesheet explosion = new Spritesheet(exploImg, ShortRect(0, 0, 256, 256));
	
	writeln("====");
	
	Transform tf = tm.getTransform();
	//	tf.setView(90, 90, 60, 60);
	
	tm.setTransform(tf);
	
	va.setIndices([0, 1, 2, 3]);

	//wnd.clear();
	//wnd.display();
	//wnd.getClock().wait(1000);
	//
	//return;

	Event event;
	
	while (wnd.isOpen()) {
		wnd.clear();
		
		//		tf.setScale(2);
		
		wnd.draw(tm);
		
		tf.setPosition(250, 50);
		tf.setScale(0.5f);
		//		tf.activate(true);
		
		wnd.draw(tm);
		
		//		tf.activate(false);
		tf.resetTranslation();
		
		wnd.draw(qs);
		wnd.draw(many);
		wnd.draw(circle);
		
		wnd.draw(wiki_sprite);
		wnd.draw(sp);
		wnd.draw(sp2);
		//wnd.draw(explosion);
		
		sp2.slideTextureRect();
		//explosion.slideTextureRect();
		
		wnd.draw(va);
		
		tof.slide();
		wnd.draw(tof);
		
		text.format("Current Fps: %d <=> %d", wnd.getClock().getCurrentFps(), wnd.getFpsLimit());
		
		/*
		 if (Keyboard.isPressed(Keyboard.Code.Left))
		 writeln("Left");
		 
		 if (Keyboard.isPressed(Keyboard.Code.Right))
		 writeln("Right");
		 */
		while (EventHandler.poll(&event)) {
			switch (event.type) { /* Process the appropriate event type */
				case Event.Type.KeyDown:  /* Handle a KEYDOWN event */
					writeln("Oh! Key press: ", event.keyboard.code);
					Time time = wnd.getClock().getTime();
					writefln("Game Loop runs now for %d ms, %d secs, %d min",
							 time.msecs, time.seconds, time.minutes);
					
					uint[] va_indices = va.fetchIndices();
					if (va_indices[0] == 1) {
						foreach (i; 0 .. 4) {
							va_indices[i] -= 1;
						}
					} else {
						foreach (i; 0 .. 4) {
							va_indices[i] += 1;
						}
					}
					
					sp.slideTextureRect();
					
					if (event.keyboard.key == Keyboard.Code.Esc) {
						EventHandler.push(Event.Type.Quit);
					} else if (event.keyboard.key == Keyboard.Code.Num1) {
						sound[0].play();
						//writeln("set color");
						//qs.getVertexAt(0).color = Color.Red;
						//qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num2) {
						sound[1].play();
						//    writeln("set color");
						//    qs.getVertexAt(1).color = Color.Cyan;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num3) {
						//    writeln("set color");
						//    qs.getVertexAt(2).color = Color.Yellow;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num4) {
						//    writeln("set color");
						//    qs.getVertexAt(3).color = Color.Magenta;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Space) {
						tm.load("../level_1.tmx");
						//Keyboard.startTextInput();
					} else if (event.keyboard.key == Keyboard.Code.KP_Enter) {
						//Keyboard.stopTextInput();
					} else {
						writeln("Make screenshot");
						wnd.capture().saveToFile("screenshot.png");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Ctrl) {
						writeln("CTRL");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Shift) {
						writeln("SHIFT");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Caps) {
						writeln("CAPS");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Alt) {
						writeln("ALT");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Gui) {
						writeln("GUI");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Mode) {
						writeln("Alt Gr");
					}
					
					if (Keyboard.getModifier() & Keyboard.Mod.Num) {
						writeln("Num Lock");
					}
					
					writefln("Mod: %d", event.keyboard.mod);
					//qs.scale(-0.5, -0.5);
					//qs.rotate(15, 0, 0);
					//qs.move(150, -25);
					
					Power powI = Power.getInfo();
					
					writefln("Es verbleiben %d second bei %d %%. Status: %s",
					         powI.seconds, powI.percent, powI.state);
					
					qs.setPixelColor(colors[cidx++ % colors.length]);
					qs.setType(Shape.Type.LineLoop);
					
					//tm.move(5, 5);
					
					/*
					 if (event.keyboard.key == Keyboard.Code.Space) {
					 Image img = new Image("../new_tilset.png");
					 tm.exchangeTileset(img);
					 } else {
					 tm.reload(Vector2s(1, 0), Vector2s(9, 4));
					 }
					 */
					
					tof.setRow(1);
					
					//					if (wnd.isFullscreen())
					//						wnd.setFullscreen(false);
					//					else
					//						wnd.setFullscreen(true);
					//					
					break;
					
				case Event.Type.MouseButtonDown:
					writefln("Mouse down at %d:%d", event.mouseButton.x, event.mouseButton.y);
					break;
					
				case Event.Type.Quit:
					wnd.close();
					break;
					
				default: break;
			}
		}
		
		wnd.draw(text);
		
		//qs.move(1, 1);
		
		wnd.display();
		
		//SDL_Delay(20);
	}
	
	writeln("\tend of main");
}