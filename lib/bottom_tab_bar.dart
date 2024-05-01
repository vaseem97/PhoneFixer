import 'package:app_trp/cart_page.dart';
import 'package:app_trp/home_page.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

import 'cart_screen.dart';
import 'model_list.dart';
import 'order_screen.dart';

class CustomMotionTabBar extends StatefulWidget {
  const CustomMotionTabBar({Key? key}) : super(key: key);

  @override
  _CustomMotionTabBarState createState() => _CustomMotionTabBarState();
}

class _CustomMotionTabBarState extends State<CustomMotionTabBar> {
  int _selectedIndex = 0;

  void _onTabItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ModelListScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrdersScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      initialSelectedTab: "Home",
      labels: const ["Home", "Cart", "Orders"],
      icons: const [Icons.home, Icons.shopping_cart, Icons.list_alt],
      tabIconSize: 30,
      tabIconColor: Colors.grey[600],
      tabSelectedColor: Colors.deepPurple,
      onTabItemSelected: _onTabItemSelected,
    );
  }
}
