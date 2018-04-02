import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'sound.dart';
import 'flutter_task.dart';
import 'dart:async';
import 'dart:math';
import "dart:io";
import 'sound.dart';
import 'flutter_task.dart';
import "text_render_object.dart";
import "package:nima/nima_flutter.dart";
import "package:nima/animation/actor_animation.dart";
import "package:flutter/animation.dart";
import "dart:ui" as ui;
import "package:flutter/scheduler.dart";

const double BACKGROUND_SCREEN_WIDTH = 1052.0;
const double BACKGROUND_SCREEN_HEIGHT = 566.0;
const double BACKGROUND_MARGIN_LEFT = 721.0;
const double BACKGROUND_MARGIN_TOP = 200.0;

Future<String> loadFileAssets(String filename) async
{
	return await rootBundle.loadString("assets/files/$filename");
}

class CodeBoxWidget extends LeafRenderObjectWidget
{
	final Offset _offset;
	final String _contents;
	// TODO: final int _colNumber;
	final double _lineNumber;
	final int _numLines;

	CodeBoxWidget(
		this._offset, 
		this._contents, 
		this._lineNumber, 
		this._numLines, 
		{Key key}) : super(key: key);

	@override
	RenderObject createRenderObject(BuildContext context)
	{
		var ro = new TextRenderObject();
		// DEBUG on Emulators ONLY:
		// loadFileAssets("main.dart").then(
		// 	(String code)
		// 	{
		// 		print("Got ${code.split('\n').length} lines of code!");
		// 		ro.text = code;
		// 	}
		// );

		return ro;
	}

	@override
	void updateRenderObject(BuildContext context, TextRenderObject renderObject) 
	{
		// print("UPDATE $_lineNumber");
		renderObject
			..text = this._contents
			..scrollValue = _lineNumber
			// ..setHighlight(3, 4)
			;
	}
}

class CodeBox extends StatefulWidget
{
	final String title;
	
	CodeBox({Key key, this.title}) : super(key:key);

	@override
	CodeBoxState createState() => new CodeBoxState();
}

class CodeBoxState extends State<CodeBox> with SingleTickerProviderStateMixin
{
	Offset _offset;
	bool _upFacing = true;
	List<Sound> _sounds;
	FlutterTask _flutterTask = new FlutterTask("~/Projects/BiggerLogo/logo_app");
	Random _rng = new Random();
	bool _ready = false;
	String _contents;
	bool _isReloading;

	AnimationController _controller;
	Animation<double> _scrollAnimation;

	@override
	initState()
	{
		super.initState();
		_controller = new AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
			..addListener(
				() {
					setState(() {
						// print("Scroll Listener!");
						_offset = new Offset(_offset.dx, _scrollAnimation.value);
					});
				}
		);
	}

	handleWebSocketMessage(msg) 
	{
		if(_isReloading || !_ready)
		{
			return;
		}
		_isReloading = true;
		setState(() 
		{
			if(_contents.indexOf("FeaturedRestaurantSimple") != -1)
			{
				_contents = _contents.replaceAll("FeaturedRestaurantSimple", "FeaturedRestaurantAligned");
			}
			else if(_contents.indexOf("CategorySimple") != -1)
			{
				_contents = _contents.replaceAll("CategorySimple", "CategoryAligned");
			}
			else if(_contents.indexOf("RestaurantsHeaderSimple") != -1)
			{
				_contents = _contents.replaceAll("RestaurantsHeaderSimple", "RestaurantsHeaderAligned");
			}
			else if(_contents.indexOf("RestaurantSimple") != -1)
			{
				_contents = _contents.replaceAll("RestaurantSimple", "RestaurantAligned");
			}
			else
			{
				// Reset.
				_contents = _contents.replaceAll("FeaturedRestaurantAligned", "FeaturedRestaurantSimple");
				_contents = _contents.replaceAll("CategoryAligned", "CategorySimple");
				_contents = _contents.replaceAll("RestaurantsHeaderAligned", "RestaurantsHeaderSimple");
				_contents = _contents.replaceAll("RestaurantAligned", "RestaurantSimple");
			}
			_flutterTask.write("/lib/main.dart", _contents).then((ok)
			{
				// Start emulator.
				_flutterTask.hotReload().then((ok)
				{
					_isReloading = false;
				});
			});
		});
	}

	CodeBoxState() :
		_offset = Offset.zero
	{
		HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080).then(
			(server) async
			{
				print("Serving at ${server.address}:${server.port}");
				await for (var request in server) 
				{
					 if (request.uri.path == '/ws') 
					 {
						// Upgrade a HttpRequest to a WebSocket connection.
						var socket = await WebSocketTransformer.upgrade(request);
						socket.listen(handleWebSocketMessage);
					}
					else
					{
						request.response
						..headers.contentType = new ContentType("text", "plain", charset: "utf-8")
						..write('Hello, world')
						..close();
					}
				}
			});

		_flutterTask.onReady(()
		{
			setState(() 
			{
				_ready = true;
			});
		});

		// Read contents.
		_flutterTask.read("/lib/main.dart").then((contents)
		{
			// Reset all widgets.
			// _contents = contents.replaceAllMapped(new RegExp(r"(FeaturedRestaurantAligned)\('"), (Match m)
			// {
			// 	return "FeaturedRestaurantSimple('";
			// });
			_contents = contents;
			if(_contents != null)
			{
				_contents = _contents.replaceAll("FeaturedRestaurantAligned", "FeaturedRestaurantSimple");
				_contents = _contents.replaceAll("CategoryAligned", "CategorySimple");
				_contents = _contents.replaceAll("RestaurantsHeaderAligned", "RestaurantsHeaderSimple");
				_contents = _contents.replaceAll("RestaurantAligned", "RestaurantSimple");
				this._offset = new Offset(0.0, 1500.0);
			}

			_flutterTask.write("/lib/main.dart", _contents).then((ok)
			{
				// Start emulator.
				_flutterTask.load("ipad").then((success)
				{
					
				});
			});
		});
		
		_sounds = new List<Sound>();
		for(int i = 1; i <= 5; i++)
		{
			Sound sound = new Sound();
			sound.load("/assets/button" + i.toString() + ".mp3");
			_sounds.add(sound); 
		}
	}

	void _scrollToPosition()
	{
		_flutterTask.hotReload();
		int idx = _rng.nextInt(_sounds.length);
		_sounds[idx].play();

		setState(() 
		{
			_controller.stop();
			
			_upFacing = !_upFacing;
			final double lineOffset = _upFacing ? 1000.0 : 0.0;
			_scrollAnimation = new Tween<double>(
				begin: this._offset.dy,
				end: lineOffset
			).animate(_controller);
			_controller
				..value = 0.0
				..animateTo(1.0, curve: Curves.easeInOut);
			this._offset = new Offset(0.0, lineOffset);
		});
	}

	@override
	Widget build(BuildContext context)
	{
		Size sz = MediaQuery.of(context).size;

		Stack stack = new Stack(
					alignment: const Alignment(0.6575, -0.22),
					children: [
						new Container(
							color: const Color.fromARGB(255, 0, 0, 0),
							width: sz.width,
							height: sz.height,
							child: new Stack(
										children: 
										[
											new Image.asset(
												"/assets/images/tv_background.png",
												bundle: rootBundle,
												width: sz.width,
												height: sz.height
											),
											new NimaWidget("/assets/nima/NPC1/NPC1")
										]
									)
						),
						new Positioned(
							left: BACKGROUND_MARGIN_LEFT,// - 500, /* TODO: remove extra margin only for simulator*/
							top: BACKGROUND_MARGIN_TOP,
							width: BACKGROUND_SCREEN_WIDTH,
							height: BACKGROUND_SCREEN_HEIGHT,
							child: new CodeBoxWidget(this._offset, this._contents, _offset.dy, 1)
						)
						],
			);

		return new Scaffold(
			body: new Center(child: stack),
			// TODO: remove this
			floatingActionButton: new FloatingActionButton(
				onPressed: _scrollToPosition,
				tooltip: "Scroll To Another Position!",
				child: new Icon(Icons.move_to_inbox)
			)
		);
	}
}

class WidgetTest extends StatelessWidget
{
	@override
	Widget build(BuildContext context)
	{
		return new MaterialApp(
			home: new CodeBox(),
		);
	}
}

void main()
{
	runApp(new WidgetTest());
}

class NimaWidget extends LeafRenderObjectWidget
{
	final String _filename;

	NimaWidget(this._filename, {Key key}): super(key: key);

	@override
	RenderObject createRenderObject(BuildContext context) 
	{
		return new NimaRenderObject(_filename);
	}

	@override
	void updateRenderObject(BuildContext context, covariant NimaRenderObject renderObject)
	{
		renderObject.filename = _filename;
	}
}

class NimaRenderObject extends RenderBox
{
	String filename;
	String _loadedFilename;//
	FlutterActor _actor;
	FlutterActor _actorInstance;
	ActorAnimation _animation;
	double _animationTime;
	double _lastFrameTime = 0.0;
	
	//final AnimationController controller = new AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

	void beginFrame(Duration timeStamp) 
	{
		final double t = timeStamp.inMicroseconds / Duration.MICROSECONDS_PER_MILLISECOND / 1000.0;
		
		if(_lastFrameTime == 0)
		{
			_lastFrameTime = t;
			SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
			// hack to circumvent not being enable to initialize lastFrameTime to a starting timeStamp (maybe it's just the date?)
			// Is the FrameCallback supposed to pass elapsed time since last frame? timeStamp seems to behave more like a date
			return;
		}

		double elapsed = t - _lastFrameTime;
		_lastFrameTime = t;
		//print("ELAPSED $elapsed");
		
		if(_actorInstance != null)
		{
			_animationTime += elapsed;
			if(_animation != null)
			{
				_animation.apply(_animationTime%2.0, _actorInstance, 1.0);
			}
			_actorInstance.advance(elapsed);
		}

		markNeedsPaint();
		//SchedulerBinding.instance.scheduleFrame();
		SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
	}

	NimaRenderObject(this.filename)
	{
		//Ticker ticker = new Ticker(this.onTick);
		//SchedulerBinding.instance.addPersistentFrameCallback(beginFrame);
		SchedulerBinding.instance.scheduleFrameCallback(beginFrame);
	}

	@override
	bool get sizedByParent => true;
	
	@override
	bool hitTestSelf(Offset screenOffset) => true;

	@override
	void performResize() 
	{
		size = constraints.biggest;
	}

	@override
	void paint(PaintingContext context, Offset offset)
	{
		//print("Paint Nima");
		final Canvas canvas = context.canvas;
		if(_actorInstance == null)
		{
			return;
		}
		canvas.save();
		canvas.scale(0.80, -0.80);
		canvas.translate(410.0, -1250.0);
		//_actorInstance.advance(0.0);
		_actorInstance.draw(canvas);
		canvas.restore();
	}

	@override
	markNeedsPaint()
	{
		if(_loadedFilename != filename)
		{
			_actor = new FlutterActor();
			_loadedFilename = filename;
			_actor.loadFromBundle(filename).then((ok)
			{
				_actorInstance = _actor;//.makeInstance();
				_animation = _actor.getAnimation("Angry");
				_animationTime = 0.0;
				markNeedsPaint();
			});
		}
		super.markNeedsPaint();
	}
}
