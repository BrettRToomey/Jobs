import PackageDescription

let vaporBeta = Version(2,0,0, prereleaseIdentifiers: ["beta"])

let package = Package(
    name: "Jobs",
	dependencies: [
		//.Package(url: "https://github.com/vdka/JSON", majorVersion: 0, minor: 16)
	]
)
