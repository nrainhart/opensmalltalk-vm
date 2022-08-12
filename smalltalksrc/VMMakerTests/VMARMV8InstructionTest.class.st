Class {
	#name : #VMARMV8InstructionTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#pools : [
		'CogRTLOpcodes'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'building suites' }
VMARMV8InstructionTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #aarch64. #wordSize -> 8 };
		yourself
]

{ #category : #configuration }
VMARMV8InstructionTest >> generateCaptureCStackPointers [
	
	^ false
]

{ #category : #tests }
VMARMV8InstructionTest >> testFcvt32BitTo64Bit [

	| result |
			
	self compile: [
		cogit MoveCq: 1.0 asIEEE32BitWord R: 0.
		cogit DupS: 32 R: 0 Vr: 0.
		cogit FcvtSs: 32 Sd: 64 Rv: 0 Rv: 0].
	
	self runGeneratedCode.
	
	result := machineSimulator v0.
	Float64Array adoptInstance: result.
	self assert: (result at: 1) equals: 1.0.
]

{ #category : #tests }
VMARMV8InstructionTest >> testMoveSIRvR [

	| expectedValue result |
	
	expectedValue := 1.0.
	self compile: [
		cogit MoveCq: expectedValue asIEEE64BitWord R: 0.
		cogit DupS: 64 R: 0 Vr: 0.
		cogit MoveS: 64 I: 0 Rv: 0 R: 1.].

	self runGeneratedCode.
	
	result := machineSimulator x0.
	self assert: (Float fromIEEE64BitWord: result) equals: expectedValue.
]
