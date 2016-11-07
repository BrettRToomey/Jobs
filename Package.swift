import PackageDescription

let package = Package(
    name: "Jobs",
	dependencies: [
		.Package(url: "https://github.com/vapor/core.git", majorVersion: 1)
	]
)
