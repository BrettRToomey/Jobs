import PackageDescription

let package = Package(
    name: "Jobs",
	dependencies: [
		.Package(url: "https://github.com/vapor/core.git", majorVersion: 1),
		.Package(url: "https://github.com/vdka/JSON", majorVersion: 0, minor: 16)
	]
)
