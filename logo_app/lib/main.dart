import 'package:flutter/material.dart';
import "featured_restaurant.dart";
import "category.dart";
import "restaurant.dart";
import "flare_widget.dart";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			title: 'Flutter Demo',
			theme: new ThemeData(
			),
			home: new MyHomePage(title: 'Flutter Demo Home Page'),
		);
	}
}


List<FeaturedRestaurantData> featuredRestaurants = <FeaturedRestaurantData>[
	const FeaturedRestaurantData("Pizza Place", description: "This energetic, farm-to-table restaurant serves up Neopolitan-inspired pizza with gelato.", deliveryTime: 15, color:const Color.fromARGB(255, 255, 223, 204), flare:"assets/flares/Pizzeria"),
	const FeaturedRestaurantData("Sushi Overload", description: "Impeccable Japanese flavors with a contemporary flair.", deliveryTime: 32, color:const Color.fromARGB(255, 237, 218, 229), flare:"assets/flares/Sushi"),
	const FeaturedRestaurantData("Burger Paradise", description: "Serves gourmet burgers, truffle fries, salads, and craft beers for lunch and dinner.", deliveryTime: 27, color:const Color.fromARGB(255, 255, 234, 216), flare:"assets/flares/Pizzeria"),
];

class MyHomePage extends StatefulWidget {
	MyHomePage({Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	@override
	Widget build(BuildContext context) {

		const double featuredRestaurantSize = 304.0;
		
		return new Container(
			decoration:new BoxDecoration(color: BACKGROUND_COLOR),
			child:
			new Stack(
				children:<Widget>[
				new ListView(
				shrinkWrap: true,
				padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
				children: <Widget>[
					featuredRestaurantSize > 10 ? new Container(
						height:featuredRestaurantSize,
						child:new FeaturedCarousel(data:featuredRestaurants, cornerRadius: FEATURED_CORNER_RADIUS, iconType:CAROUSEL_ICON_TYPE, fontSize:14.0),
					) : 
					new Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>
						[
							new Container(
								padding:const EdgeInsets.fromLTRB(60.0, 15.0, 0.0, 10.0),
								child:new Text("Featured", 
									style:const TextStyle(fontSize:13.0,color:Colors.black, decoration: TextDecoration.none)),
							),
							new Container(
								height:210.0,
								child:new ListView(
									shrinkWrap: true,
									padding:const EdgeInsets.fromLTRB(60.0, 0.0, 0.0, 0.0),
									scrollDirection: Axis.horizontal,
									children: <Widget> [
										const FeaturedRestaurantAligned('Pizza Place', description: "This energetic, farmers-to-table restaurant serves up Neopolitan-inspired pizza and gelato.", deliveryTime:15, cornerRadius:FEATURED_CORNER_RADIUS, fontSize:14.0),
										const FeaturedRestaurantAligned('Sushi Overload', description: "Impeccable Japanese flavors with a contemporary flair.", deliveryTime:32, cornerRadius:FEATURED_CORNER_RADIUS, fontSize:14.0),
										const FeaturedRestaurantAligned('Burger Paradise', description: "Umami Burgers serves burgers, fries...", deliveryTime:45, cornerRadius:FEATURED_CORNER_RADIUS, fontSize:14.0)
									]
								)
							)
						]
					),
					new Container(
						height:133.0,
						child:new ListView(
							shrinkWrap: true,
							padding:const EdgeInsets.fromLTRB(60.0, 0.0, 0.0, 0.0),
							scrollDirection: Axis.horizontal,
							children: <Widget> [
								const CategoryDesigned('Pizza', flare:PIZZA_ICON, fontSize:14.0),
								const CategoryDesigned('Burgers', flare:BURGER_ICON, fontSize:14.0),
								const CategoryDesigned('Dessert', flare:DESSERT_ICON, fontSize:14.0),
								const CategoryDesigned('Sushi', fontSize:14.0),
								const CategoryDesigned('Chinese', fontSize:14.0),
							]
						)
					),
					new RestaurantsHeaderDesigned(),
					const ListRestaurantDesigned('Indian Food', cornerRadius:LIST_CORNER_RADIUS, description:"Indian Street Food", deliveryTime: 29, rating: 9, dollarSigns: 2, img:"assets/images/samosa.jpg", padding:60.0),
					const ListRestaurantDesigned('Fancy Cafe', cornerRadius:LIST_CORNER_RADIUS, description:"Salads", deliveryTime: 29, rating: 9, dollarSigns: 2, img:"assets/images/cafe.jpg", padding:60.0),
					const ListRestaurantDesigned('Asian Fare', cornerRadius:LIST_CORNER_RADIUS, description:"Fresh Sustainable Asian Street Food", deliveryTime: 29, rating: 9, dollarSigns: 2, img:"assets/images/pizza.jpg", padding:60.0),
					const ListRestaurantDesigned('Fresh from Hawaii', cornerRadius:LIST_CORNER_RADIUS, description:"Hawaiian", deliveryTime: 29, rating: 9, dollarSigns: 2, img:"assets/images/poke.jpg", padding:60.0),
				],
			),
			new Container(padding:const EdgeInsets.fromLTRB(60.0, 30.0, 0.0, 0.0), alignment: Alignment.topLeft, child:new Flare("assets/flares/MenuIcon")),
			new Container(padding:const EdgeInsets.fromLTRB(0.0, 30.0, 60.0, 0.0), alignment: Alignment.topRight, child:new Flare("assets/flares/SearchIcon"))
			])
		);
	}
}