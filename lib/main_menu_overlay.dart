import 'package:flutter/material.dart';

import 'main.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({
    Key? key,
    required this.game,
  }) : super(key: key);

  final MyGame game;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: game.viewport.canvasSize.y,
        width: game.viewport.canvasSize.x,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: mainMenuImage,
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // const SizedBox(
                //   height: 32.0,
                // ),
                // const SizedBox(
                //   height: 32.0,
                // ),
                // const SizedBox(
                //   height: 32.0,
                // ),
                MaterialButton(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  textColor: Colors.white,
                  splashColor: Colors.greenAccent,
                  elevation: 8.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      image:
                          DecorationImage(image: buttonImage, fit: BoxFit.fill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "      Start      ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.03,
                        ),
                      ),
                    ),
                  ),
                  // ),
                  onPressed: () {
                    // Go to the Main Menu
                    game.reset();
                  },
                ),
                // MaterialButton(
                //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                //   textColor: Colors.white,
                //   splashColor: Colors.greenAccent,
                //   elevation: 8.0,
                //   child: Container(
                //     decoration: const BoxDecoration(
                //       image:
                //           DecorationImage(image: buttonImage, fit: BoxFit.fill),
                //     ),
                //     child: Padding(
                //       padding: EdgeInsets.all(8.0),
                //       child: Text(
                //         "    Deposit    ",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: width * 0.03,
                //         ),
                //       ),
                //     ),
                //   ),
                //   // ),
                //   onPressed: () {
                //     // Show QR code
                //   },
                // ),
                // MaterialButton(
                //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                //   textColor: Colors.white,
                //   splashColor: Colors.greenAccent,
                //   elevation: 8.0,
                //   child: Container(
                //     decoration: const BoxDecoration(
                //       image:
                //           DecorationImage(image: buttonImage, fit: BoxFit.fill),
                //     ),
                //     child: Padding(
                //       padding: EdgeInsets.all(8.0),
                //       child: Text(
                //         "    Leader Boards    ",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: width * 0.03,
                //         ),
                //       ),
                //     ),
                //   ),
                //   // ),
                //   onPressed: () {
                //     // Show QR code
                //   },
                // ),
              ],
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
            const SizedBox(
              width: 32.0,
            ),
          ],
        ),
      ),
    );
  }
}
