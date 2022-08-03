Class {
	#name : #VMJittedFloat64ArrayAdd,
	#superclass : #VMJittedPrimitivesTest,
	#instVars : [
		'stop'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMJittedFloat64ArrayAdd >> setUp [

	super setUp.

	initialAddress := self
		compile: [ 
			cogit objectRepresentation genPrimitiveFloat64ArrayAdd.
			stop := cogit Stop ]
		bytecodes: 10.
]

{ #category : #tests }
VMJittedFloat64ArrayAdd >> testPrimitiveFloat64ArrayAdd [

	| array1 array2 resultArray |

	array1 := self new64BitIndexableFromArray: #(1 2 3 4).
	array2 := self new64BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new64BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat64: 0 ofObject: resultArray) equals: 11.0.
	self assert: (memory fetchFloat64: 1 ofObject: resultArray) equals: 22.0.
	self assert: (memory fetchFloat64: 2 ofObject: resultArray) equals: 33.0.
	self assert: (memory fetchFloat64: 3 ofObject: resultArray) equals: 44.0.
]

{ #category : #tests }
VMJittedFloat64ArrayAdd >> testPrimitiveFloat64ArrayAddFailsIfFirstOperandIsNotFloat64Array [

	| array1 array2 resultArray |

	array1 := self new32BitIndexableFromArray: #(1 2 3 4).
	array2 := self new64BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new64BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat64ArrayAdd >> testPrimitiveFloat64ArrayAddFailsIfOperandArrayIsSmallerThanResultArray [

	| array1 array2 resultArray |

	array1 := self new64BitIndexableFromArray: #(1 2).
	array2 := self new64BitIndexableFromArray: #(10 20).
	resultArray := self new64BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat64: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat64: 1 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat64: 2 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat64: 3 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat64ArrayAdd >> testPrimitiveFloat64ArrayAddFailsIfResultArgumentIsNotFloat64Array [

	| array1 array2 resultArray |

	array1 := self new64BitIndexableFromArray: #(1 2 3 4).
	array2 := self new64BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new32BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
]

{ #category : #tests }
VMJittedFloat64ArrayAdd >> testPrimitiveFloat64ArrayAddFailsIfSecondOperandIsNotFloat64Array [

	| array1 array2 resultArray |

	array1 := self new64BitIndexableFromArray: #(1 2 3 4).
	array2 := self new32BitIndexableFromArray: #(10 20 30 40).
	resultArray := self new64BitIndexableFromArray: #(0 0 0 0).

	self
		prepareStackForSendReceiver: (memory integerObjectOf: 0)
		arguments: { array1. array2. resultArray }.

	machineSimulator baseRegisterValue: cogit varBaseAddress.

	self runUntilReturn.

	self assert: (memory fetchFloat32: 0 ofObject: resultArray) equals: 0.0.
	self assert: (memory fetchFloat32: 1 ofObject: resultArray) equals: 0.0.
]
