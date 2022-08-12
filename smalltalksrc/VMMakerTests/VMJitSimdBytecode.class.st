Class {
	#name : #VMJitSimdBytecode,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #tests }
VMJitSimdBytecode class >> testParameters [ 

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'aarch64'. #wordSize -> 8};
		addCase: { #ISA -> #'X64'. #wordSize -> 8};
		yourself
]

{ #category : #running }
VMJitSimdBytecode >> jitOptions [

	^ super jitOptions
		  at: #bytecodeTableInitializer put: #initializeBytecodeTableForSistaV1;
		  yourself
]

{ #category : #running }
VMJitSimdBytecode >> setUp [

	super setUp.
	self setUpTrampolines.
]

{ #category : #running }
VMJitSimdBytecode >> setUpTrampolines [
	
	cogit ceSendMustBeBooleanAddFalseTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddFalseTrampoline).
	cogit ceSendMustBeBooleanAddTrueTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddTrueTrampoline).
]

{ #category : #tests }
VMJitSimdBytecode >> testAddVector32CopiesArraySumIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	array := self new32BitIndexableFromArray: #(1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0).
	arguments := { memory integerObjectOf: 0.  array. memory integerObjectOf: 4 }.		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.
								 cogit genPushFloat32ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat32ArrayToRegister.
								 cogit genAddFloat32Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register floatAt: 1) equals: 6.0.
	self assert: (register floatAt: 5) equals: 8.0.
	self assert: (register floatAt: 9) equals: 10.0.
	self assert: (register floatAt: 13) equals: 12.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testAddVectorCopiesArraySumIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 0. array. memory integerObjectOf: 2 }.	
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 4.0.
	self assert: (register doubleAt: 9) equals: 6.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testAddVectorPushesArraySumIntoSimulatedStack [

	| endInstruction primitiveAddress array entry |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 0. array. memory integerObjectOf: 2 }.
	
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	"The register with the result is the same as the first one"
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 0.

]

{ #category : #tests }
VMJitSimdBytecode >> testCannotPush32BitArrayTo64BitPerLaneRegister [

	| endInstruction primitiveAddress array register |
	
	array := self new32BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 2.  array }.		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 0.0.
	self assert: (register doubleAt: 9) equals: 0.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testCannotPushArrayToRegisterIfIndexIsNotInteger [

	| endInstruction primitiveAddress array register |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory trueObject. "Not a valid index"  array }.		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 0.0.
	self assert: (register doubleAt: 9) equals: 0.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testCannotPushArrayToRegisterIfIndexIsOutOfBounds [

	| endInstruction primitiveAddress array register |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerValueOf: 3. "Out of bounds index"  array }.		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 0.0.
	self assert: (register doubleAt: 9) equals: 0.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testPushArrayToRegisterCopiesArrayChunkIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 2.  array }. 		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 3.0.
	self assert: (register doubleAt: 9) equals: 4.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testPushArrayToRegisterPushesArrayChunkIntoSimulatedStack [

	| endInstruction primitiveAddress array entry |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 2.  array }.		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 0.
]

{ #category : #tests }
VMJitSimdBytecode >> testPushFloat32RegisterElementBytecode [

	| endInstruction primitiveAddress array entry register |
	
	array := self new32BitIndexableFromArray: #(5.0 3.0 2.0 1.0).
	arguments := { memory integerObjectOf: 1.  array. memory integerObjectOf: 0 }.		
		
	sentSelector := #-."TODO is this necessary?"
	self buildStackFrame.
	
	primitiveAddress := self compile: [
								 cogit genPushTemporaryVariable: 0.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat32ArrayToRegister.
								 cogit genPushFloat32RegisterElement.		
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	
	self assert: (entry type) equals: SSRegister.
	self assert: (entry register) equals: 20.
	
	register := machineSimulator x20.
	
	self assert: (Float fromIEEE64BitWord: register) equals: 3.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testStoreRegisterIntoArrayReplacesArrayElementsWithRegisterContent [

	| endInstruction primitiveAddress array |
	
	array := self new64BitIndexableFromArray: #(1.0 2.0 3.0 4.0).
	arguments := { memory integerObjectOf: 2.  array. memory integerObjectOf: 0 }.	
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.
								 cogit genStoreFloat64RegisterIntoArray.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	self assert: (memory fetchFloat64: 0 ofObject: array) equals: 3.0.
	self assert: (memory fetchFloat64: 1 ofObject: array) equals: 4.0.
]

{ #category : #tests }
VMJitSimdBytecode >> testSubVectorStoreResultIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	array := self new64BitIndexableFromArray: #(5.0 3.0 2.0 1.0).
	arguments := { memory integerObjectOf: 0.  array. memory integerObjectOf: 2 }.		
		
	sentSelector := #-."TODO is this necessary?"
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genSubFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 3.0.
	self assert: (register doubleAt: 9) equals: 2.0.

]
