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
			"NVS",
			"GPIO",
            "SPIFFS",
            "Files",
            "Logging",
            "JSON",
		])
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

		.target(name: "CClosures"),

        .target(name: "CLogging"),
        .target(name: "Logging", dependencies: ["CLogging"]),

        .target(name: "CFiles"),
        .target(name: "Files", dependencies: ["CFiles"]),

		.target(name: "CGPIO"),
		.target(name: "GPIO", dependencies: [ "CGPIO" ]),

		.target(name: "CFreeRTOS"),
		.target(name: "FreeRTOS", dependencies: ["CFreeRTOS"]),

		.target(name: "CEventLoop"),
		.target(name: "EventLoop", dependencies: ["CEventLoop", "CClosures", "FreeRTOS"]),

		.target(name: "CEspWiFi"),
		.target(name: "WiFi", dependencies: ["CEspWiFi", "FreeRTOS", "EventLoop", "NVS"]),

		.target(name: "CHttpServer"),
		.target(name: "HttpServer", dependencies: [
            "CHttpServer",
            "CClosures",
            "Files",
            "Logging",
        ]),

        .target(name: "CJSON"),
        .target(name: "JSON", dependencies: ["CJSON", "Files"]),

		.target(name: "CNVS"),
		.target(name: "NVS", dependencies: ["CNVS"]),

        .target(name: "CSPIFFS"),
        .target(name: "SPIFFS", dependencies: ["CSPIFFS"]),
    ]
)
