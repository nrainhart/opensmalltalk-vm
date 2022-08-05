Class {
	#name : #VMJittedFloat32ArrayAdd,
	#superclass : #VMJittedPrimitivesTest,
	#instVars : [
		'stop'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMJittedFloat32ArrayAdd >> setUp [

	super setUp.

	initialAddress := self
		compile: [ 
			cogit objectRepresentation genPrimitiveFloat32ArrayAdd.
			stop := cogit Stop ]
		bytecodes: 10.
]

{ #category : #tests }
VMJittedFloat32ArrayAdd >> testPrimitiveFloat32ArrayAdd [

	| array1 array2 resultArray |

	array1 := self new32BitIndexableFromArray: #(1 2 3 4).
	array2 := self new32BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new32BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 11.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 22.0.
	self assert: (memory fetchFloat32: 2 ofObject: resultArray) equals: 33.0.
	self assert: (memory fetchFloat32: 3 ofObject: resultArray) equals: 44.0.
]

{ #category : #tests }
VMJittedFloat32ArrayAdd >> testPrimitiveFloat32ArrayAddFailsIfFirstOperandIsNotFloat32Array [

	| array1 array2 resultArray |

	array1 := self new64BitIndexableFromArray: #(1 2 3 4).
	array2 := self new32BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new32BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 2 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 3 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat32ArrayAdd >> testPrimitiveFloat32ArrayAddFailsIfOperandArrayIsSmallerThanResultArray [

	| array1 array2 resultArray |

	array1 := self new32BitIndexableFromArray: #(1 2).
	array2 := self new32BitIndexableFromArray: #(10 20).
	resultArray := self new32BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 2 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 3 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat32ArrayAdd >> testPrimitiveFloat32ArrayAddFailsIfResultArgumentIsNotFloat32Array [

	| array1 array2 resultArray |

	array1 := self new32BitIndexableFromArray: #(1 2 3 4).
	array2 := self new32BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new64BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 2 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 3 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat32ArrayAdd >> testPrimitiveFloat32ArrayAddFailsIfSecondOperandIsNotFloat32Array [

	| array1 array2 resultArray |

	array1 := self new32BitIndexableFromArray: #(1 2 3 4).
	array2 := self new64BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new32BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 2 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 3 ofObject: resultArray) equals: 0.0.
]
