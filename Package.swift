// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EspSwift",
	
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
		.library(name: "EspSwift", targets: [
			"EventLoop",
			"FreeRTOS",
			"WiFi",
			"HttpServer",
		])
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

		.target(name: "CClosures"),

		.target(name: "CEventLoop"),
		.target(name: "EventLoop", dependencies: ["CEventLoop", "CClosures"]),

		.target(name: "CFreeRTOS"),
		.target(name: "FreeRTOS", dependencies: ["CFreeRTOS"]),

		.target(name: "CEspWiFi"),
		.target(name: "WiFi", dependencies: ["CEspWiFi", "FreeRTOS", "EventLoop"]),

		.target(name: "CHttpServer"),
		.target(name: "HttpServer", dependencies: ["CHttpServer", "CClosures"]),
    ]
)
