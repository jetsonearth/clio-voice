-------------------------------------
Translated Report (Full Report Below)
-------------------------------------

Process:               Clio [2759]
Path:                  /Applications/Clio.app/Contents/MacOS/Clio
Identifier:            com.cliovoice.clio
Version:               1.0.9 (109)
Code Type:             ARM-64 (Native)
Parent Process:        launchd [1]
User ID:               501

Date/Time:             2025-07-28 23:51:07.4062 +0800
OS Version:            macOS 14.5 (23F79)
Report Version:        12
Anonymous UUID:        E5B72D03-86A0-23FA-46D9-B406AECBD6A2


Time Awake Since Boot: 4500 seconds

System Integrity Protection: enabled

Crashed Thread:        0  Dispatch queue: com.apple.main-thread

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000

Termination Reason:    Namespace SIGNAL, Code 6 Abort trap: 6
Terminating Process:   Clio [2759]

Application Specific Information:
abort() called


Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
0   libsystem_kernel.dylib        	       0x19c072a60 __pthread_kill + 8
1   libsystem_pthread.dylib       	       0x19c0aac20 pthread_kill + 288
2   libsystem_c.dylib             	       0x19bfb7a30 abort + 180
3   libswiftCore.dylib            	       0x1ac11d9f4 swift::fatalErrorv(unsigned int, char const*, char*) + 128
4   libswiftCore.dylib            	       0x1ac11da14 swift::fatalError(unsigned int, char const*, ...) + 32
5   libswiftCore.dylib            	       0x1ac13122c getSuperclassMetadata + 816
6   libswiftCore.dylib            	       0x1ac1314c4 _swift_initClassMetadataImpl(swift::TargetClassMetadata<swift::InProcess, swift::TargetAnyClassMetadataObjCInterop<swift::InProcess>>*, swift::ClassLayoutFlags, unsigned long, swift::TypeLayout const* const*, unsigned long*, bool) + 84
7   _AVKit_SwiftUI                	       0x2326efea0 0x2326eb000 + 20128
8   libswiftCore.dylib            	       0x1ac13dcac swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::doInitialization(swift::MetadataWaitQueue::Worker&, swift::MetadataRequest) + 772
9   libswiftCore.dylib            	       0x1ac12cdc4 _swift_getGenericMetadata(swift::MetadataRequest, void const* const*, swift::TargetTypeContextDescriptor<swift::InProcess> const*) + 2744
10  _AVKit_SwiftUI                	       0x2326efe14 __swift_instantiateGenericMetadata + 36
11  libswiftCore.dylib            	       0x1ac15f038 (anonymous namespace)::DecodedMetadataBuilder::createBoundGenericType(swift::TargetContextDescriptor<swift::InProcess> const*, __swift::__runtime::llvm::ArrayRef<swift::MetadataOrPack>, swift::MetadataOrPack) const + 604
12  libswiftCore.dylib            	       0x1ac15d3e8 swift::Demangle::__runtime::TypeDecoder<(anonymous namespace)::DecodedMetadataBuilder>::decodeMangledType(swift::Demangle::__runtime::Node*, unsigned int, bool) + 11624
13  libswiftCore.dylib            	       0x1ac15755c swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 892
14  libswiftCore.dylib            	       0x1ac157100 swift_getTypeByMangledNode + 836
15  libswiftCore.dylib            	       0x1ac157bb0 swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 1172
16  libswiftCore.dylib            	       0x1ac151a84 swift_getTypeByMangledName + 836
17  libswiftCore.dylib            	       0x1ac13ac18 swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*) + 432
18  libswiftCore.dylib            	       0x1ac138c80 swift_getAssociatedTypeWitness + 92
19  libswiftCore.dylib            	       0x1ac162738 (anonymous namespace)::DecodedMetadataBuilder::createDependentMemberType(__swift::__runtime::llvm::StringRef, swift::MetadataOrPack, swift::TargetProtocolDescriptorRef<swift::InProcess>) const + 1032
20  libswiftCore.dylib            	       0x1ac15d458 swift::Demangle::__runtime::TypeDecoder<(anonymous namespace)::DecodedMetadataBuilder>::decodeMangledType(swift::Demangle::__runtime::Node*, unsigned int, bool) + 11736
21  libswiftCore.dylib            	       0x1ac15755c swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 892
22  libswiftCore.dylib            	       0x1ac157100 swift_getTypeByMangledNode + 836
23  libswiftCore.dylib            	       0x1ac157bb0 swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 1172
24  libswiftCore.dylib            	       0x1ac151a84 swift_getTypeByMangledName + 836
25  libswiftCore.dylib            	       0x1ac13ac18 swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*) + 432
26  libswiftCore.dylib            	       0x1ac138c80 swift_getAssociatedTypeWitness + 92
27  SwiftUI                       	       0x1c91120c4 0x1c7a1c000 + 24076484
28  libswiftCore.dylib            	       0x1ac13dcac swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::doInitialization(swift::MetadataWaitQueue::Worker&, swift::MetadataRequest) + 772
29  libswiftCore.dylib            	       0x1ac12cdc4 _swift_getGenericMetadata(swift::MetadataRequest, void const* const*, swift::TargetTypeContextDescriptor<swift::InProcess> const*) + 2744
30  SwiftUI                       	       0x1c7a39ff0 __swift_instantiateGenericMetadata + 36
31  SwiftUI                       	       0x1c90e1204 0x1c7a1c000 + 23876100
32  SwiftUI                       	       0x1c7b155b4 0x1c7a1c000 + 1021364
33  AttributeGraph                	       0x1c970b5c0 AG::Graph::UpdateStack::update() + 512
34  AttributeGraph                	       0x1c970bdfc AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int) + 424
35  AttributeGraph                	       0x1c9714848 AG::Graph::input_value_ref_slow(AG::data::ptr<AG::Node>, AG::AttributeID, unsigned int, unsigned int, AGSwiftMetadata const*, unsigned char&, long) + 720
36  AttributeGraph                	       0x1c972cccc AGGraphGetValue + 228
37  SwiftUI                       	       0x1c90e394c 0x1c7a1c000 + 23886156
38  SwiftUI                       	       0x1c90e3b3c 0x1c7a1c000 + 23886652
39  SwiftUI                       	       0x1c7b155b4 0x1c7a1c000 + 1021364
40  AttributeGraph                	       0x1c970b5c0 AG::Graph::UpdateStack::update() + 512
41  AttributeGraph                	       0x1c970bdfc AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int) + 424
42  AttributeGraph                	       0x1c9714668 AG::Graph::input_value_ref_slow(AG::data::ptr<AG::Node>, AG::AttributeID, unsigned int, unsigned int, AGSwiftMetadata const*, unsigned char&, long) + 240
43  AttributeGraph                	       0x1c972ca7c AGGraphGetInputValue + 248
44  SwiftUI                       	       0x1c84a2a8c 0x1c7a1c000 + 11037324
45  SwiftUI                       	       0x1c9104098 0x1c7a1c000 + 24019096
46  SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
47  SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
48  SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
49  SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
50  SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
51  SwiftUI                       	       0x1c84a2eb0 0x1c7a1c000 + 11038384
52  SwiftUI                       	       0x1c8068328 0x1c7a1c000 + 6603560
53  SwiftUI                       	       0x1c9103e10 0x1c7a1c000 + 24018448
54  SwiftUI                       	       0x1c88ff580 0x1c7a1c000 + 15611264
55  SwiftUI                       	       0x1c88feb98 0x1c7a1c000 + 15608728
56  SwiftUI                       	       0x1c88ff348 0x1c7a1c000 + 15610696
57  SwiftUI                       	       0x1c88ff5d8 0x1c7a1c000 + 15611352
58  SwiftUI                       	       0x1c92346b8 0x1c7a1c000 + 25265848
59  SwiftUI                       	       0x1c88ff428 0x1c7a1c000 + 15610920
60  SwiftUI                       	       0x1c88ff5d8 0x1c7a1c000 + 15611352
61  SwiftUI                       	       0x1c92346b8 0x1c7a1c000 + 25265848
62  SwiftUI                       	       0x1c921a68c 0x1c7a1c000 + 25159308
63  SwiftUI                       	       0x1c80686ac 0x1c7a1c000 + 6604460
64  SwiftUI                       	       0x1c9104b20 0x1c7a1c000 + 24021792
65  SwiftUI                       	       0x1c88ff580 0x1c7a1c000 + 15611264
66  SwiftUI                       	       0x1c88feb98 0x1c7a1c000 + 15608728
67  SwiftUI                       	       0x1c88ff348 0x1c7a1c000 + 15610696
68  SwiftUI                       	       0x1c88ff5d8 0x1c7a1c000 + 15611352
69  SwiftUI                       	       0x1c92346b8 0x1c7a1c000 + 25265848
70  SwiftUI                       	       0x1c87380d0 0x1c7a1c000 + 13746384
71  SwiftUI                       	       0x1c8738c60 0x1c7a1c000 + 13749344
72  SwiftUI                       	       0x1c87368d4 0x1c7a1c000 + 13740244
73  SwiftUI                       	       0x1c863e6a0 0x1c7a1c000 + 12723872
74  SwiftUI                       	       0x1c863edd0 0x1c7a1c000 + 12725712
75  SwiftUI                       	       0x1c8c2e354 0x1c7a1c000 + 18948948
76  SwiftUI                       	       0x1c8c2e120 0x1c7a1c000 + 18948384
77  SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
78  SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
79  SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
80  SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
81  SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
82  SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
83  SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
84  SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
85  SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
86  SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
87  SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
88  SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
89  SwiftUI                       	       0x1c9232a5c 0x1c7a1c000 + 25258588
90  SwiftUI                       	       0x1c92345c4 0x1c7a1c000 + 25265604
91  SwiftUI                       	       0x1c88973e0 0x1c7a1c000 + 15184864
92  SwiftUI                       	       0x1c87384b8 0x1c7a1c000 + 13747384
93  SwiftUI                       	       0x1c8737cb4 0x1c7a1c000 + 13745332
94  SwiftUI                       	       0x1c8738c60 0x1c7a1c000 + 13749344
95  SwiftUI                       	       0x1c87368d4 0x1c7a1c000 + 13740244
96  SwiftUI                       	       0x1c863e6a0 0x1c7a1c000 + 12723872
97  SwiftUI                       	       0x1c863edd0 0x1c7a1c000 + 12725712
98  SwiftUI                       	       0x1c8c2e354 0x1c7a1c000 + 18948948
99  SwiftUI                       	       0x1c8c2e120 0x1c7a1c000 + 18948384
100 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
101 SwiftUI                       	       0x1c864b848 0x1c7a1c000 + 12777544
102 SwiftUI                       	       0x1c864c030 0x1c7a1c000 + 12779568
103 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
104 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
105 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
106 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
107 SwiftUI                       	       0x1c864b848 0x1c7a1c000 + 12777544
108 SwiftUI                       	       0x1c864c030 0x1c7a1c000 + 12779568
109 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
110 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
111 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
112 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
113 SwiftUI                       	       0x1c864b848 0x1c7a1c000 + 12777544
114 SwiftUI                       	       0x1c864c030 0x1c7a1c000 + 12779568
115 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
116 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
117 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
118 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
119 SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
120 SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
121 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
122 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
123 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
124 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
125 SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
126 SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
127 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
128 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
129 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
130 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
131 SwiftUI                       	       0x1c8ef3f18 0x1c7a1c000 + 21856024
132 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
133 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
134 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
135 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
136 SwiftUI                       	       0x1c8ef3f18 0x1c7a1c000 + 21856024
137 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
138 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
139 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
140 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
141 SwiftUI                       	       0x1c8738024 0x1c7a1c000 + 13746212
142 SwiftUI                       	       0x1c8738c60 0x1c7a1c000 + 13749344
143 SwiftUI                       	       0x1c87368d4 0x1c7a1c000 + 13740244
144 SwiftUI                       	       0x1c863e6a0 0x1c7a1c000 + 12723872
145 SwiftUI                       	       0x1c863edd0 0x1c7a1c000 + 12725712
146 SwiftUI                       	       0x1c8c2e354 0x1c7a1c000 + 18948948
147 SwiftUI                       	       0x1c8c2e120 0x1c7a1c000 + 18948384
148 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
149 SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
150 SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
151 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
152 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
153 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
154 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
155 SwiftUI                       	       0x1c84a2eb0 0x1c7a1c000 + 11038384
156 SwiftUI                       	       0x1c9259a10 0x1c7a1c000 + 25418256
157 SwiftUI                       	       0x1c8c2e354 0x1c7a1c000 + 18948948
158 SwiftUI                       	       0x1c8c2e120 0x1c7a1c000 + 18948384
159 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
160 SwiftUI                       	       0x1c8738024 0x1c7a1c000 + 13746212
161 SwiftUI                       	       0x1c8738c60 0x1c7a1c000 + 13749344
162 SwiftUI                       	       0x1c87368d4 0x1c7a1c000 + 13740244
163 SwiftUI                       	       0x1c863e6a0 0x1c7a1c000 + 12723872
164 SwiftUI                       	       0x1c863edd0 0x1c7a1c000 + 12725712
165 SwiftUI                       	       0x1c8c2e354 0x1c7a1c000 + 18948948
166 SwiftUI                       	       0x1c8c2e120 0x1c7a1c000 + 18948384
167 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
168 SwiftUI                       	       0x1c9104110 0x1c7a1c000 + 24019216
169 SwiftUI                       	       0x1c9104b7c 0x1c7a1c000 + 24021884
170 SwiftUI                       	       0x1c88ffa98 0x1c7a1c000 + 15612568
171 SwiftUI                       	       0x1c88ff91c 0x1c7a1c000 + 15612188
172 SwiftUI                       	       0x1c88ff5c0 0x1c7a1c000 + 15611328
173 SwiftUI                       	       0x1c9234520 0x1c7a1c000 + 25265440
174 SwiftUI                       	       0x1c86d4538 0x1c7a1c000 + 13337912
175 SwiftUI                       	       0x1c8077d38 0x1c7a1c000 + 6667576
176 AttributeGraph                	       0x1c970b5c0 AG::Graph::UpdateStack::update() + 512
177 AttributeGraph                	       0x1c970bdfc AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int) + 424
178 AttributeGraph                	       0x1c971a7ac AG::Subgraph::update(unsigned int) + 848
179 SwiftUI                       	       0x1c900c650 0x1c7a1c000 + 23004752
180 SwiftUI                       	       0x1c900dc7c 0x1c7a1c000 + 23010428
181 SwiftUI                       	       0x1c86d4aa0 0x1c7a1c000 + 13339296
182 SwiftUI                       	       0x1c90d0294 0x1c7a1c000 + 23806612
183 SwiftUI                       	       0x1c90cebc0 0x1c7a1c000 + 23800768
184 SwiftUI                       	       0x1c86cce64 0x1c7a1c000 + 13307492
185 SwiftUI                       	       0x1c900dc44 0x1c7a1c000 + 23010372
186 SwiftUI                       	       0x1c900db30 0x1c7a1c000 + 23010096
187 SwiftUI                       	       0x1c89779a4 0x1c7a1c000 + 16103844
188 SwiftUI                       	       0x1c7feca28 0x1c7a1c000 + 6097448
189 SwiftUI                       	       0x1c7fec974 0x1c7a1c000 + 6097268
190 SwiftUI                       	       0x1c7fecac8 0x1c7a1c000 + 6097608
191 CoreFoundation                	       0x19c18987c __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 36
192 CoreFoundation                	       0x19c189768 __CFRunLoopDoObservers + 536
193 CoreFoundation                	       0x19c188480 CFRunLoopRunSpecific + 684
194 HIToolbox                     	       0x1a692c19c RunCurrentEventLoopInMode + 292
195 HIToolbox                     	       0x1a692be2c ReceiveNextEventCommon + 220
196 HIToolbox                     	       0x1a692bd30 _BlockUntilNextEventMatchingListInModeWithFilter + 76
197 AppKit                        	       0x19f9e7d68 _DPSNextEvent + 660
198 AppKit                        	       0x1a01dd808 -[NSApplication(NSEventRouting) _nextEventMatchingEventMask:untilDate:inMode:dequeue:] + 700
199 AppKit                        	       0x19f9db09c -[NSApplication run] + 476
200 AppKit                        	       0x19f9b22e0 NSApplicationMain + 880
201 SwiftUI                       	       0x1c7b26474 0x1c7a1c000 + 1090676
202 SwiftUI                       	       0x1c828fe88 0x1c7a1c000 + 8863368
203 SwiftUI                       	       0x1c868aeb8 0x1c7a1c000 + 13037240
204 Clio                          	       0x104caa1dc 0x104b04000 + 1728988
205 dyld                          	       0x19bd220e0 start + 2360

Thread 1:
0   libsystem_pthread.dylib       	       0x19c0a5d20 start_wqthread + 0

Thread 2::  Dispatch queue: com.apple.root.utility-qos
0   libsystem_kernel.dylib        	       0x19c0781dc __ulock_wait2 + 8
1   libsystem_platform.dylib      	       0x19c0d9238 _os_unfair_lock_lock_slow + 188
2   libswiftCore.dylib            	       0x1ac13d774 swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::awaitSatisfyingState(swift::ConcurrencyControl&, swift::MetadataRequest) + 260
3   libswiftCore.dylib            	       0x1ac139970 swift::MetadataResponse performOnMetadataCache<swift::MetadataResponse, swift_checkMetadataState::CheckStateCallbacks>(swift::TargetMetadata<swift::InProcess> const*, swift_checkMetadataState::CheckStateCallbacks&&) + 740
4   libswiftCore.dylib            	       0x1ac139680 swift_checkMetadataState + 36
5   libswiftCore.dylib            	       0x1ac1575a0 swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 960
6   libswiftCore.dylib            	       0x1ac157100 swift_getTypeByMangledNode + 836
7   libswiftCore.dylib            	       0x1ac157bb0 swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>) + 1172
8   libswiftCore.dylib            	       0x1ac151a84 swift_getTypeByMangledName + 836
9   libswiftCore.dylib            	       0x1ac151ecc swift_getTypeByMangledNameInContextImpl(char const*, unsigned long, swift::TargetContextDescriptor<swift::InProcess> const*, void const* const*) + 172
10  AttributeGraph                	       0x1c9707cb4 AG::swift::metadata::mangled_type_name_ref(char const*, bool, AG::swift::metadata::ref_kind*) const + 212
11  AttributeGraph                	       0x1c97085a4 AG::swift::metadata_visitor::visit_field(AG::swift::metadata const*, AG::swift::field_record const&, unsigned long, unsigned long) + 80
12  AttributeGraph                	       0x1c9707b4c AG::swift::metadata::visit(AG::swift::metadata_visitor&) const + 1244
13  AttributeGraph                	       0x1c97202f0 AG::LayoutDescriptor::make_layout(AG::swift::metadata const*, AGComparisonMode, AG::LayoutDescriptor::HeapMode) + 580
14  AttributeGraph                	       0x1c9721b44 AG::(anonymous namespace)::TypeDescriptorCache::drain_queue(void*) + 348
15  libdispatch.dylib             	       0x19befa3e8 _dispatch_client_callout + 20
16  libdispatch.dylib             	       0x19bf0c080 _dispatch_root_queue_drain + 864
17  libdispatch.dylib             	       0x19bf0c6b8 _dispatch_worker_thread2 + 156
18  libsystem_pthread.dylib       	       0x19c0a6fd0 _pthread_wqthread + 228
19  libsystem_pthread.dylib       	       0x19c0a5d28 start_wqthread + 8

Thread 3:: caulk.messenger.shared:17
0   libsystem_kernel.dylib        	       0x19c06a170 semaphore_wait_trap + 8
1   caulk                         	       0x1a6623624 caulk::semaphore::timed_wait(double) + 212
2   caulk                         	       0x1a66234d8 caulk::concurrent::details::worker_thread::run() + 36
3   caulk                         	       0x1a66231d8 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 96
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 4:: caulk.messenger.shared:high
0   libsystem_kernel.dylib        	       0x19c06a170 semaphore_wait_trap + 8
1   caulk                         	       0x1a6623624 caulk::semaphore::timed_wait(double) + 212
2   caulk                         	       0x1a66234d8 caulk::concurrent::details::worker_thread::run() + 36
3   caulk                         	       0x1a66231d8 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 96
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 5:: caulk::deferred_logger
0   libsystem_kernel.dylib        	       0x19c06a170 semaphore_wait_trap + 8
1   caulk                         	       0x1a6623624 caulk::semaphore::timed_wait(double) + 212
2   caulk                         	       0x1a66234d8 caulk::concurrent::details::worker_thread::run() + 36
3   caulk                         	       0x1a66231d8 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 96
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 6:
0   libsystem_pthread.dylib       	       0x19c0a5d20 start_wqthread + 0

Thread 7:
0   libsystem_pthread.dylib       	       0x19c0a5d20 start_wqthread + 0

Thread 8:
0   libsystem_pthread.dylib       	       0x19c0a5d20 start_wqthread + 0

Thread 9:: com.apple.audio.toolbox.AUScheduledParameterRefresher
0   libsystem_kernel.dylib        	       0x19c06a170 semaphore_wait_trap + 8
1   caulk                         	       0x1a6623624 caulk::semaphore::timed_wait(double) + 212
2   caulk                         	       0x1a66234d8 caulk::concurrent::details::worker_thread::run() + 36
3   caulk                         	       0x1a66231d8 void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*) + 96
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 10:: AQConverterThread
0   libsystem_kernel.dylib        	       0x19c06d9ec __psynch_cvwait + 8
1   libsystem_pthread.dylib       	       0x19c0ab55c _pthread_cond_wait + 1228
2   libAudioToolboxUtility.dylib  	       0x1ab113ce4 CADeprecated::CAGuard::Wait() + 76
3   AudioToolbox                  	       0x1ac3eaf78 AQConverterManager::AQConverterThread::ConverterThreadEntry(void*) + 572
4   libAudioToolboxUtility.dylib  	       0x1ab0f0254 CADeprecated::CAPThread::Entry(CADeprecated::CAPThread*) + 92
5   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
6   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 11:: com.apple.NSURLConnectionLoader
0   libsystem_kernel.dylib        	       0x19c06a1f4 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x19c07cb24 mach_msg2_internal + 80
2   libsystem_kernel.dylib        	       0x19c072e34 mach_msg_overwrite + 476
3   libsystem_kernel.dylib        	       0x19c06a578 mach_msg + 24
4   CoreFoundation                	       0x19c18a680 __CFRunLoopServiceMachPort + 160
5   CoreFoundation                	       0x19c188f44 __CFRunLoopRun + 1208
6   CoreFoundation                	       0x19c188434 CFRunLoopRunSpecific + 608
7   CFNetwork                     	       0x1a1624a18 0x1a13c5000 + 2488856
8   Foundation                    	       0x19d2b5f80 __NSThread__start__ + 716
9   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
10  libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 12:: com.apple.NSEventThread
0   libsystem_kernel.dylib        	       0x19c06a1f4 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	       0x19c07cb24 mach_msg2_internal + 80
2   libsystem_kernel.dylib        	       0x19c072e34 mach_msg_overwrite + 476
3   libsystem_kernel.dylib        	       0x19c06a578 mach_msg + 24
4   CoreFoundation                	       0x19c18a680 __CFRunLoopServiceMachPort + 160
5   CoreFoundation                	       0x19c188f44 __CFRunLoopRun + 1208
6   CoreFoundation                	       0x19c188434 CFRunLoopRunSpecific + 608
7   AppKit                        	       0x19fb12188 _NSEventThread + 144
8   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
9   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 13:: com.apple.coremedia.sharedRootQueue.48
0   libsystem_kernel.dylib        	       0x19c06a188 semaphore_timedwait_trap + 8
1   libdispatch.dylib             	       0x19befaa00 _dispatch_sema4_timedwait + 64
2   libdispatch.dylib             	       0x19befaffc _dispatch_semaphore_wait_slow + 76
3   libdispatch.dylib             	       0x19bf0bc7c _dispatch_worker_thread + 328
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 14:: com.apple.coremedia.sharedRootQueue.49
0   libsystem_kernel.dylib        	       0x19c06a188 semaphore_timedwait_trap + 8
1   libdispatch.dylib             	       0x19befaa00 _dispatch_sema4_timedwait + 64
2   libdispatch.dylib             	       0x19befaffc _dispatch_semaphore_wait_slow + 76
3   libdispatch.dylib             	       0x19bf0bc7c _dispatch_worker_thread + 328
4   libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
5   libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8

Thread 15:: com.apple.coremedia.sharedRootQueue.47 Dispatch queue: CommonURLAssetNotificationQueue
0   AVFCore                       	       0x1b1b1f9bc -[AVFigAssetInspectorLoader _invokeCompletionHandlerForLoadingBatches:] + 868
1   AVFCore                       	       0x1b1b1d56c handleFigAssetLoadingNotification + 564
2   CoreFoundation                	       0x19c17f130 __CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__ + 128
3   CoreFoundation                	       0x19c2133d8 ___CFXRegistrationPost_block_invoke + 88
4   CoreFoundation                	       0x19c213320 _CFXRegistrationPost + 440
5   CoreFoundation                	       0x19c14d678 _CFXNotificationPost + 768
6   CoreFoundation                	       0x19c17f220 CFNotificationCenterPostNotificationWithOptions + 136
7   CoreMedia                     	       0x1a6653744 CMNotificationCenterPostNotification + 128
8   CoreMedia                     	       0x1a66589a8 figDeferredPostNotification + 40
9   libdispatch.dylib             	       0x19befa3e8 _dispatch_client_callout + 20
10  libdispatch.dylib             	       0x19bf01a14 _dispatch_lane_serial_drain + 748
11  libdispatch.dylib             	       0x19bf02578 _dispatch_lane_invoke + 432
12  libdispatch.dylib             	       0x19bf0bea8 _dispatch_root_queue_drain + 392
13  libdispatch.dylib             	       0x19bf0bc38 _dispatch_worker_thread + 260
14  libsystem_pthread.dylib       	       0x19c0aaf94 _pthread_start + 136
15  libsystem_pthread.dylib       	       0x19c0a5d34 thread_start + 8


Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2: 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x00000000000001c0   x5: 0x0000000000000020   x6: 0x00006000008cd5e0   x7: 0x0000000000000000
    x8: 0x5a2e30054ab513c2   x9: 0x5a2e3007495b5fc2  x10: 0x00003e095a010000  x11: 0x0000000000000070
   x12: 0x000060000212b320  x13: 0x00000000001ff800  x14: 0x00000000000007fb  x15: 0x00000000b781a033
   x16: 0x0000000000000148  x17: 0x000000020e299928  x18: 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x0000000203ee4c00  x21: 0x0000000000000103  x22: 0x0000000203ee4ce0  x23: 0x000000011d25cc70
   x24: 0x000000016b2ef228  x25: 0x00000000000000ff  x26: 0x00000002326f2a94  x27: 0x00000000000000ff
   x28: 0x00006000021219d8   fp: 0x000000016b2ef0c0   lr: 0x000000019c0aac20
    sp: 0x000000016b2ef0a0   pc: 0x000000019c072a60 cpsr: 0x40001000
   far: 0x0000000000000000  esr: 0x56000080  Address size fault

Binary Images:
       0x11c664000 -        0x11c667fff com.apple.icloud.drive.fileprovider.override (1.0) <db39a641-8c34-385d-8faf-37cb3dcfc89e> /System/Library/Frameworks/FileProvider.framework/OverrideBundles/iCloudDriveFileProviderOverride.bundle/Contents/MacOS/iCloudDriveFileProviderOverride
       0x11c748000 -        0x11c767fff com.apple.findersync.fileprovideroverride.FinderSyncCollaborationFileProviderOverride (14.5) <45b63a1f-97c2-3047-9430-120757ec26f6> /System/Library/Frameworks/FileProvider.framework/OverrideBundles/FinderSyncCollaborationFileProviderOverride.bundle/Contents/MacOS/FinderSyncCollaborationFileProviderOverride
       0x11c6ac000 -        0x11c6b3fff com.apple.FileProviderOverride (1835.120.53) <48c78787-aebf-3b9c-8300-2b20ba87b0a4> /System/Library/Frameworks/FileProvider.framework/OverrideBundles/FileProviderOverride.bundle/Contents/MacOS/FileProviderOverride
       0x1468c4000 -        0x1468e3fff com.apple.security.csparser (3.0) <5b38c00e-20a2-3dd5-b582-3d7bf058f0ba> /System/Library/Frameworks/Security.framework/Versions/A/PlugIns/csparser.bundle/Contents/MacOS/csparser
       0x11ba00000 -        0x11c2dffff com.apple.audio.codecs.Components (7.0) <10dc413b-3923-3f80-8a3d-35aacaaa801e> /System/Library/Components/AudioCodecs.component/Contents/MacOS/AudioCodecs
       0x107dac000 -        0x107ee3fff com.apple.audio.units.Components (1.14) <fd93a3bc-5142-33ea-88bd-c2258c5a032d> /System/Library/Components/CoreAudio.component/Contents/MacOS/CoreAudio
       0x1053dc000 -        0x1053e7fff libobjc-trampolines.dylib (*) <9381bd6d-84a5-3c72-b3b8-88428afa4782> /usr/lib/libobjc-trampolines.dylib
       0x1057c4000 -        0x105807fff org.sparkle-project.Sparkle (2.7.0) <e1818fcc-1225-3d7d-ab35-30d26f536a6a> /Applications/Clio.app/Contents/Frameworks/Sparkle.framework/Versions/B/Sparkle
       0x105c30000 -        0x105d63fff org.ggml.whisper (1.0) <a954dee5-970f-3cd5-ad33-6c3c0b325b03> /Applications/Clio.app/Contents/Frameworks/whisper.framework/Versions/A/whisper
       0x104b04000 -        0x105137fff com.cliovoice.clio (1.0.9) <5bceaace-2fbf-3dcc-b919-3b1fd849e195> /Applications/Clio.app/Contents/MacOS/Clio
       0x19c069000 -        0x19c0a3ffb libsystem_kernel.dylib (*) <9b8b53f9-e2b6-36df-98e9-28d8fca732f2> /usr/lib/system/libsystem_kernel.dylib
       0x19c0a4000 -        0x19c0b0fff libsystem_pthread.dylib (*) <386b0fc1-7873-3328-8e71-43269fd1b2c7> /usr/lib/system/libsystem_pthread.dylib
       0x19bf41000 -        0x19bfbfff7 libsystem_c.dylib (*) <05b44e93-dffc-3bd8-90ab-fd97cb73f171> /usr/lib/system/libsystem_c.dylib
       0x1abd74000 -        0x1ac2d1fff libswiftCore.dylib (*) <c2fd0f69-d72c-37a5-938e-1bd710c88431> /usr/lib/swift/libswiftCore.dylib
       0x2326eb000 -        0x2326f2ff1 _AVKit_SwiftUI (*) <db7863c4-ea47-301b-ab7e-01f6476f9413> /System/Library/Frameworks/_AVKit_SwiftUI.framework/Versions/A/_AVKit_SwiftUI
       0x1c7a1c000 -        0x1c96fffff com.apple.SwiftUI (5.5.8) <71c9cc70-1a85-396b-a92a-c893fe8bd541> /System/Library/Frameworks/SwiftUI.framework/Versions/A/SwiftUI
       0x1c9700000 -        0x1c9744fff com.apple.AttributeGraph (5.4.16) <fffe46a2-2d66-3719-b6ca-69d9760ce96f> /System/Library/PrivateFrameworks/AttributeGraph.framework/Versions/A/AttributeGraph
       0x19c10c000 -        0x19c5e4fff com.apple.CoreFoundation (6.9) <84b539d5-22c9-3f8c-84c8-903e9c7b8d29> /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
       0x1a68f9000 -        0x1a6bbcfff com.apple.HIToolbox (2.1.1) <7db6c397-563f-3756-908c-e25b019a1848> /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/HIToolbox
       0x19f9ae000 -        0x1a0ceafff com.apple.AppKit (6.9) <61f710be-9132-3cc2-883d-066365fba1ad> /System/Library/Frameworks/AppKit.framework/Versions/C/AppKit
       0x19bd1c000 -        0x19bda4a17 dyld (*) <37bbc384-0755-31c7-a808-0ed49e44dd8e> /usr/lib/dyld
               0x0 - 0xffffffffffffffff ??? (*) <00000000-0000-0000-0000-000000000000> ???
       0x19c0d7000 -        0x19c0defe7 libsystem_platform.dylib (*) <d5bbfc31-d52a-37d6-a41b-48638113ad4c> /usr/lib/system/libsystem_platform.dylib
       0x19bef6000 -        0x19bf3dfff libdispatch.dylib (*) <502762ee-7aa7-306c-9dbd-88981a86bb78> /usr/lib/system/libdispatch.dylib
       0x1a6621000 -        0x1a664afff com.apple.audio.caulk (1.0) <f2da6e2e-b5a0-3ce7-97f5-7d2141a3ec32> /System/Library/PrivateFrameworks/caulk.framework/Versions/A/caulk
       0x1ab0e3000 -        0x1ab11bfff libAudioToolboxUtility.dylib (*) <cf1cffc5-2961-3894-b753-80ac364540d5> /usr/lib/libAudioToolboxUtility.dylib
       0x1ac3c2000 -        0x1ac541fff com.apple.audio.toolbox.AudioToolbox (1.14) <b1800481-82d6-39e7-9500-8c14e3d786c9> /System/Library/Frameworks/AudioToolbox.framework/Versions/A/AudioToolbox
       0x1a13c5000 -        0x1a1798fff com.apple.CFNetwork (1.0) <0af09533-3214-3182-a742-0c04a20f38d1> /System/Library/Frameworks/CFNetwork.framework/Versions/A/CFNetwork
       0x19d261000 -        0x19debefff com.apple.Foundation (6.9) <99e0292d-7873-3968-9c9c-5955638689a5> /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
       0x1b1a3e000 -        0x1b1c89fff com.apple.AVFCore (1.0) <2eda8725-a1c6-3a86-9276-07c1c9626621> /System/Library/PrivateFrameworks/AVFCore.framework/Versions/A/AVFCore
       0x1a664b000 -        0x1a6793fff com.apple.CoreMedia (1.0) <560bc822-f6a0-3d59-82e3-dc919489b341> /System/Library/Frameworks/CoreMedia.framework/Versions/A/CoreMedia

External Modification Summary:
  Calls made by other processes targeting this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by this process:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0
  Calls made by all processes on this machine:
    task_for_pid: 0
    thread_create: 0
    thread_set_state: 0

VM Region Summary:
ReadOnly portion of Libraries: Total=1.4G resident=0K(0%) swapped_out_or_unallocated=1.4G(100%)
Writable regions: Total=1.8G written=0K(0%) resident=0K(0%) swapped_out=0K(0%) unallocated=1.8G(100%)

                                VIRTUAL   REGION 
REGION TYPE                        SIZE    COUNT (non-coalesced) 
===========                     =======  ======= 
Accelerate framework               128K        1 
Activity Tracing                   256K        1 
AttributeGraph Data               1024K        1 
CG image                           144K        5 
ColorSync                          592K       29 
CoreAnimation                     20.8M      101 
CoreData Object IDs               4112K        2 
CoreGraphics                        32K        2 
CoreUI image data                 1456K       10 
Foundation                          16K        1 
Kernel Alloc Once                   32K        1 
MALLOC                             1.7G       87 
MALLOC guard page                  480K       30 
MALLOC_LARGE (reserved)           26.4M        1         reserved VM address space (unallocated)
SQLite page cache                  512K        4 
STACK GUARD                       56.2M       16 
Stack                             16.0M       16 
VM_ALLOCATE                       15.1M       38 
__AUTH                            3384K      574 
__AUTH_CONST                      40.3M      823 
__CTF                               824        1 
__DATA                            18.9M      817 
__DATA_CONST                      41.7M      841 
__DATA_DIRTY                      2853K      316 
__FONT_DATA                          4K        1 
__INFO_FILTER                         8        1 
__LINKEDIT                       535.5M       11 
__OBJC_RO                         71.9M        1 
__OBJC_RW                         2199K        1 
__TEXT                           875.7M      861 
dyld private memory                272K        2 
libnetwork                         128K        8 
mapped file                      306.3M       49 
shared memory                     1872K       14 
===========                     =======  ======= 
TOTAL                              3.7G     4667 
TOTAL, minus reserved VM space     3.7G     4667 



-----------
Full Report
-----------

{"app_name":"Clio","timestamp":"2025-07-28 23:51:07.00 +0800","app_version":"1.0.9","slice_uuid":"5bceaace-2fbf-3dcc-b919-3b1fd849e195","build_version":"109","platform":1,"bundleID":"com.cliovoice.clio","share_with_app_devs":0,"is_first_party":0,"bug_type":"309","os_version":"macOS 14.5 (23F79)","roots_installed":0,"name":"Clio","incident_id":"330ABC28-A060-4743-8639-9FBCB76FC8F4"}
{
  "uptime" : 4500,
  "procRole" : "Foreground",
  "version" : 2,
  "userID" : 501,
  "deployVersion" : 210,
  "modelCode" : "Mac15,3",
  "coalitionID" : 2567,
  "osVersion" : {
    "train" : "macOS 14.5",
    "build" : "23F79",
    "releaseType" : "User"
  },
  "captureTime" : "2025-07-28 23:51:07.4062 +0800",
  "codeSigningMonitor" : 1,
  "incident" : "330ABC28-A060-4743-8639-9FBCB76FC8F4",
  "pid" : 2759,
  "translated" : false,
  "cpuType" : "ARM-64",
  "roots_installed" : 0,
  "bug_type" : "309",
  "procLaunch" : "2025-07-28 23:50:48.7333 +0800",
  "procStartAbsTime" : 108325185844,
  "procExitAbsTime" : 108773107967,
  "procName" : "Clio",
  "procPath" : "\/Applications\/Clio.app\/Contents\/MacOS\/Clio",
  "bundleInfo" : {"CFBundleShortVersionString":"1.0.9","CFBundleVersion":"109","CFBundleIdentifier":"com.cliovoice.clio"},
  "storeInfo" : {"deviceIdentifierForVendor":"F40FB30D-373B-5B2B-982A-B3BFE84BA207","thirdParty":true},
  "parentProc" : "launchd",
  "parentPid" : 1,
  "coalitionName" : "com.cliovoice.clio",
  "crashReporterKey" : "E5B72D03-86A0-23FA-46D9-B406AECBD6A2",
  "lowContext Preset" : 1,
  "codeSigningID" : "com.cliovoice.clio",
  "codeSigningTeamID" : "MFDGY9T8T9",
  "codeSigningFlags" : 570520337,
  "codeSigningValidationCategory" : 6,
  "codeSigningTrustLevel" : 4294967295,
  "instructionByteStream" : {"beforePC":"fyMD1f17v6n9AwCRW+D\/l78DAJH9e8Go\/w9f1sADX9YQKYDSARAA1A==","atPC":"AwEAVH8jA9X9e7+p\/QMAkVDg\/5e\/AwCR\/XvBqP8PX9bAA1\/WcAqA0g=="},
  "sip" : "enabled",
  "exception" : {"codes":"0x0000000000000000, 0x0000000000000000","rawCodes":[0,0],"type":"EXC_CRASH","signal":"SIGABRT"},
  "termination" : {"flags":0,"code":6,"namespace":"SIGNAL","indicator":"Abort trap: 6","byProc":"Clio","byPid":2759},
  "asi" : {"libsystem_c.dylib":["abort() called"]},
  "extMods" : {"caller":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"system":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"targeted":{"thread_create":0,"thread_set_state":0,"task_for_pid":0},"warnings":0},
  "faultingThread" : 0,
  "threads" : [{"triggered":true,"id":66036,"threadState":{"x":[{"value":0},{"value":0},{"value":0},{"value":0},{"value":448},{"value":32},{"value":105553125496288},{"value":0},{"value":6498184111628555202},{"value":6498184120195833794},{"value":68209885642752},{"value":112},{"value":105553151046432},{"value":2095104},{"value":2043},{"value":3078725683},{"value":328},{"value":8827541800},{"value":0},{"value":6},{"value":8655883264,"symbolLocation":0,"symbol":"_main_thread"},{"value":259},{"value":8655883488,"symbolLocation":224,"symbol":"_main_thread"},{"value":4783983728},{"value":6093206056},{"value":255},{"value":9436080788},{"value":255},{"value":105553151007192}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6912912416},"cpsr":{"value":1073745920},"fp":{"value":6093205696},"sp":{"value":6093205664},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912682592,"matchesCrashFrame":1},"far":{"value":0}},"queue":"com.apple.main-thread","frames":[{"imageOffset":39520,"symbol":"__pthread_kill","symbolLocation":8,"imageIndex":10},{"imageOffset":27680,"symbol":"pthread_kill","symbolLocation":288,"imageIndex":11},{"imageOffset":485936,"symbol":"abort","symbolLocation":180,"imageIndex":12},{"imageOffset":3840500,"symbol":"swift::fatalErrorv(unsigned int, char const*, char*)","symbolLocation":128,"imageIndex":13},{"imageOffset":3840532,"symbol":"swift::fatalError(unsigned int, char const*, ...)","symbolLocation":32,"imageIndex":13},{"imageOffset":3920428,"symbol":"getSuperclassMetadata","symbolLocation":816,"imageIndex":13},{"imageOffset":3921092,"symbol":"_swift_initClassMetadataImpl(swift::TargetClassMetadata<swift::InProcess, swift::TargetAnyClassMetadataObjCInterop<swift::InProcess>>*, swift::ClassLayoutFlags, unsigned long, swift::TypeLayout const* const*, unsigned long*, bool)","symbolLocation":84,"imageIndex":13},{"imageOffset":20128,"imageIndex":14},{"imageOffset":3972268,"symbol":"swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::doInitialization(swift::MetadataWaitQueue::Worker&, swift::MetadataRequest)","symbolLocation":772,"imageIndex":13},{"imageOffset":3902916,"symbol":"_swift_getGenericMetadata(swift::MetadataRequest, void const* const*, swift::TargetTypeContextDescriptor<swift::InProcess> const*)","symbolLocation":2744,"imageIndex":13},{"imageOffset":19988,"symbol":"__swift_instantiateGenericMetadata","symbolLocation":36,"imageIndex":14},{"imageOffset":4108344,"symbol":"(anonymous namespace)::DecodedMetadataBuilder::createBoundGenericType(swift::TargetContextDescriptor<swift::InProcess> const*, __swift::__runtime::llvm::ArrayRef<swift::MetadataOrPack>, swift::MetadataOrPack) const","symbolLocation":604,"imageIndex":13},{"imageOffset":4101096,"symbol":"swift::Demangle::__runtime::TypeDecoder<(anonymous namespace)::DecodedMetadataBuilder>::decodeMangledType(swift::Demangle::__runtime::Node*, unsigned int, bool)","symbolLocation":11624,"imageIndex":13},{"imageOffset":4076892,"symbol":"swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":892,"imageIndex":13},{"imageOffset":4075776,"symbol":"swift_getTypeByMangledNode","symbolLocation":836,"imageIndex":13},{"imageOffset":4078512,"symbol":"swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":1172,"imageIndex":13},{"imageOffset":4053636,"symbol":"swift_getTypeByMangledName","symbolLocation":836,"imageIndex":13},{"imageOffset":3959832,"symbol":"swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*)","symbolLocation":432,"imageIndex":13},{"imageOffset":3951744,"symbol":"swift_getAssociatedTypeWitness","symbolLocation":92,"imageIndex":13},{"imageOffset":4122424,"symbol":"(anonymous namespace)::DecodedMetadataBuilder::createDependentMemberType(__swift::__runtime::llvm::StringRef, swift::MetadataOrPack, swift::TargetProtocolDescriptorRef<swift::InProcess>) const","symbolLocation":1032,"imageIndex":13},{"imageOffset":4101208,"symbol":"swift::Demangle::__runtime::TypeDecoder<(anonymous namespace)::DecodedMetadataBuilder>::decodeMangledType(swift::Demangle::__runtime::Node*, unsigned int, bool)","symbolLocation":11736,"imageIndex":13},{"imageOffset":4076892,"symbol":"swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":892,"imageIndex":13},{"imageOffset":4075776,"symbol":"swift_getTypeByMangledNode","symbolLocation":836,"imageIndex":13},{"imageOffset":4078512,"symbol":"swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":1172,"imageIndex":13},{"imageOffset":4053636,"symbol":"swift_getTypeByMangledName","symbolLocation":836,"imageIndex":13},{"imageOffset":3959832,"symbol":"swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*)","symbolLocation":432,"imageIndex":13},{"imageOffset":3951744,"symbol":"swift_getAssociatedTypeWitness","symbolLocation":92,"imageIndex":13},{"imageOffset":24076484,"imageIndex":15},{"imageOffset":3972268,"symbol":"swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::doInitialization(swift::MetadataWaitQueue::Worker&, swift::MetadataRequest)","symbolLocation":772,"imageIndex":13},{"imageOffset":3902916,"symbol":"_swift_getGenericMetadata(swift::MetadataRequest, void const* const*, swift::TargetTypeContextDescriptor<swift::InProcess> const*)","symbolLocation":2744,"imageIndex":13},{"imageOffset":122864,"symbol":"__swift_instantiateGenericMetadata","symbolLocation":36,"imageIndex":15},{"imageOffset":23876100,"imageIndex":15},{"imageOffset":1021364,"imageIndex":15},{"imageOffset":46528,"symbol":"AG::Graph::UpdateStack::update()","symbolLocation":512,"imageIndex":16},{"imageOffset":48636,"symbol":"AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int)","symbolLocation":424,"imageIndex":16},{"imageOffset":84040,"symbol":"AG::Graph::input_value_ref_slow(AG::data::ptr<AG::Node>, AG::AttributeID, unsigned int, unsigned int, AGSwiftMetadata const*, unsigned char&, long)","symbolLocation":720,"imageIndex":16},{"imageOffset":183500,"symbol":"AGGraphGetValue","symbolLocation":228,"imageIndex":16},{"imageOffset":23886156,"imageIndex":15},{"imageOffset":23886652,"imageIndex":15},{"imageOffset":1021364,"imageIndex":15},{"imageOffset":46528,"symbol":"AG::Graph::UpdateStack::update()","symbolLocation":512,"imageIndex":16},{"imageOffset":48636,"symbol":"AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int)","symbolLocation":424,"imageIndex":16},{"imageOffset":83560,"symbol":"AG::Graph::input_value_ref_slow(AG::data::ptr<AG::Node>, AG::AttributeID, unsigned int, unsigned int, AGSwiftMetadata const*, unsigned char&, long)","symbolLocation":240,"imageIndex":16},{"imageOffset":182908,"symbol":"AGGraphGetInputValue","symbolLocation":248,"imageIndex":16},{"imageOffset":11037324,"imageIndex":15},{"imageOffset":24019096,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":11038384,"imageIndex":15},{"imageOffset":6603560,"imageIndex":15},{"imageOffset":24018448,"imageIndex":15},{"imageOffset":15611264,"imageIndex":15},{"imageOffset":15608728,"imageIndex":15},{"imageOffset":15610696,"imageIndex":15},{"imageOffset":15611352,"imageIndex":15},{"imageOffset":25265848,"imageIndex":15},{"imageOffset":15610920,"imageIndex":15},{"imageOffset":15611352,"imageIndex":15},{"imageOffset":25265848,"imageIndex":15},{"imageOffset":25159308,"imageIndex":15},{"imageOffset":6604460,"imageIndex":15},{"imageOffset":24021792,"imageIndex":15},{"imageOffset":15611264,"imageIndex":15},{"imageOffset":15608728,"imageIndex":15},{"imageOffset":15610696,"imageIndex":15},{"imageOffset":15611352,"imageIndex":15},{"imageOffset":25265848,"imageIndex":15},{"imageOffset":13746384,"imageIndex":15},{"imageOffset":13749344,"imageIndex":15},{"imageOffset":13740244,"imageIndex":15},{"imageOffset":12723872,"imageIndex":15},{"imageOffset":12725712,"imageIndex":15},{"imageOffset":18948948,"imageIndex":15},{"imageOffset":18948384,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25258588,"imageIndex":15},{"imageOffset":25265604,"imageIndex":15},{"imageOffset":15184864,"imageIndex":15},{"imageOffset":13747384,"imageIndex":15},{"imageOffset":13745332,"imageIndex":15},{"imageOffset":13749344,"imageIndex":15},{"imageOffset":13740244,"imageIndex":15},{"imageOffset":12723872,"imageIndex":15},{"imageOffset":12725712,"imageIndex":15},{"imageOffset":18948948,"imageIndex":15},{"imageOffset":18948384,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":12777544,"imageIndex":15},{"imageOffset":12779568,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":12777544,"imageIndex":15},{"imageOffset":12779568,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":12777544,"imageIndex":15},{"imageOffset":12779568,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":21856024,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":21856024,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":13746212,"imageIndex":15},{"imageOffset":13749344,"imageIndex":15},{"imageOffset":13740244,"imageIndex":15},{"imageOffset":12723872,"imageIndex":15},{"imageOffset":12725712,"imageIndex":15},{"imageOffset":18948948,"imageIndex":15},{"imageOffset":18948384,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":11038384,"imageIndex":15},{"imageOffset":25418256,"imageIndex":15},{"imageOffset":18948948,"imageIndex":15},{"imageOffset":18948384,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":13746212,"imageIndex":15},{"imageOffset":13749344,"imageIndex":15},{"imageOffset":13740244,"imageIndex":15},{"imageOffset":12723872,"imageIndex":15},{"imageOffset":12725712,"imageIndex":15},{"imageOffset":18948948,"imageIndex":15},{"imageOffset":18948384,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":24019216,"imageIndex":15},{"imageOffset":24021884,"imageIndex":15},{"imageOffset":15612568,"imageIndex":15},{"imageOffset":15612188,"imageIndex":15},{"imageOffset":15611328,"imageIndex":15},{"imageOffset":25265440,"imageIndex":15},{"imageOffset":13337912,"imageIndex":15},{"imageOffset":6667576,"imageIndex":15},{"imageOffset":46528,"symbol":"AG::Graph::UpdateStack::update()","symbolLocation":512,"imageIndex":16},{"imageOffset":48636,"symbol":"AG::Graph::update_attribute(AG::data::ptr<AG::Node>, unsigned int)","symbolLocation":424,"imageIndex":16},{"imageOffset":108460,"symbol":"AG::Subgraph::update(unsigned int)","symbolLocation":848,"imageIndex":16},{"imageOffset":23004752,"imageIndex":15},{"imageOffset":23010428,"imageIndex":15},{"imageOffset":13339296,"imageIndex":15},{"imageOffset":23806612,"imageIndex":15},{"imageOffset":23800768,"imageIndex":15},{"imageOffset":13307492,"imageIndex":15},{"imageOffset":23010372,"imageIndex":15},{"imageOffset":23010096,"imageIndex":15},{"imageOffset":16103844,"imageIndex":15},{"imageOffset":6097448,"imageIndex":15},{"imageOffset":6097268,"imageIndex":15},{"imageOffset":6097608,"imageIndex":15},{"imageOffset":514172,"symbol":"__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__","symbolLocation":36,"imageIndex":17},{"imageOffset":513896,"symbol":"__CFRunLoopDoObservers","symbolLocation":536,"imageIndex":17},{"imageOffset":509056,"symbol":"CFRunLoopRunSpecific","symbolLocation":684,"imageIndex":17},{"imageOffset":209308,"symbol":"RunCurrentEventLoopInMode","symbolLocation":292,"imageIndex":18},{"imageOffset":208428,"symbol":"ReceiveNextEventCommon","symbolLocation":220,"imageIndex":18},{"imageOffset":208176,"symbol":"_BlockUntilNextEventMatchingListInModeWithFilter","symbolLocation":76,"imageIndex":18},{"imageOffset":236904,"symbol":"_DPSNextEvent","symbolLocation":660,"imageIndex":19},{"imageOffset":8583176,"symbol":"-[NSApplication(NSEventRouting) _nextEventMatchingEventMask:untilDate:inMode:dequeue:]","symbolLocation":700,"imageIndex":19},{"imageOffset":184476,"symbol":"-[NSApplication run]","symbolLocation":476,"imageIndex":19},{"imageOffset":17120,"symbol":"NSApplicationMain","symbolLocation":880,"imageIndex":19},{"imageOffset":1090676,"imageIndex":15},{"imageOffset":8863368,"imageIndex":15},{"imageOffset":13037240,"imageIndex":15},{"imageOffset":1728988,"imageIndex":9},{"imageOffset":24800,"symbol":"start","symbolLocation":2360,"imageIndex":20}]},{"id":66100,"frames":[{"imageOffset":7456,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":11}],"threadState":{"x":[{"value":6093811712},{"value":6147},{"value":6093275136},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6093811712},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912892192},"far":{"value":0}}},{"id":66101,"threadState":{"x":[{"value":18446744073709551612},{"value":0},{"value":258},{"value":0},{"value":0},{"value":8735229608,"symbolLocation":848,"symbol":"vtable for dyld4::APIs"},{"value":4783980144},{"value":0},{"value":258},{"value":259},{"value":0},{"value":0},{"value":1},{"value":1},{"value":4783980144},{"value":4783980144},{"value":544},{"value":8827541968},{"value":0},{"value":5379},{"value":0},{"value":0},{"value":105553162430600},{"value":16777218},{"value":258},{"value":0},{"value":4294967295},{"value":5379},{"value":4783980776}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6913102392},"cpsr":{"value":1073745920},"fp":{"value":6094380032},"sp":{"value":6094379952},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912704988},"far":{"value":0}},"queue":"com.apple.root.utility-qos","frames":[{"imageOffset":61916,"symbol":"__ulock_wait2","symbolLocation":8,"imageIndex":10},{"imageOffset":8760,"symbol":"_os_unfair_lock_lock_slow","symbolLocation":188,"imageIndex":22},{"imageOffset":3970932,"symbol":"swift::MetadataCacheEntryBase<(anonymous namespace)::GenericCacheEntry, void const*>::awaitSatisfyingState(swift::ConcurrencyControl&, swift::MetadataRequest)","symbolLocation":260,"imageIndex":13},{"imageOffset":3955056,"symbol":"swift::MetadataResponse performOnMetadataCache<swift::MetadataResponse, swift_checkMetadataState::CheckStateCallbacks>(swift::TargetMetadata<swift::InProcess> const*, swift_checkMetadataState::CheckStateCallbacks&&)","symbolLocation":740,"imageIndex":13},{"imageOffset":3954304,"symbol":"swift_checkMetadataState","symbolLocation":36,"imageIndex":13},{"imageOffset":4076960,"symbol":"swift_getTypeByMangledNodeImpl(swift::MetadataRequest, swift::Demangle::__runtime::Demangler&, swift::Demangle::__runtime::Node*, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":960,"imageIndex":13},{"imageOffset":4075776,"symbol":"swift_getTypeByMangledNode","symbolLocation":836,"imageIndex":13},{"imageOffset":4078512,"symbol":"swift_getTypeByMangledNameImpl(swift::MetadataRequest, __swift::__runtime::llvm::StringRef, void const* const*, std::__1::function<void const* (unsigned int, unsigned int)>, std::__1::function<swift::TargetWitnessTable<swift::InProcess> const* (swift::TargetMetadata<swift::InProcess> const*, unsigned int)>)","symbolLocation":1172,"imageIndex":13},{"imageOffset":4053636,"symbol":"swift_getTypeByMangledName","symbolLocation":836,"imageIndex":13},{"imageOffset":4054732,"symbol":"swift_getTypeByMangledNameInContextImpl(char const*, unsigned long, swift::TargetContextDescriptor<swift::InProcess> const*, void const* const*)","symbolLocation":172,"imageIndex":13},{"imageOffset":31924,"symbol":"AG::swift::metadata::mangled_type_name_ref(char const*, bool, AG::swift::metadata::ref_kind*) const","symbolLocation":212,"imageIndex":16},{"imageOffset":34212,"symbol":"AG::swift::metadata_visitor::visit_field(AG::swift::metadata const*, AG::swift::field_record const&, unsigned long, unsigned long)","symbolLocation":80,"imageIndex":16},{"imageOffset":31564,"symbol":"AG::swift::metadata::visit(AG::swift::metadata_visitor&) const","symbolLocation":1244,"imageIndex":16},{"imageOffset":131824,"symbol":"AG::LayoutDescriptor::make_layout(AG::swift::metadata const*, AGComparisonMode, AG::LayoutDescriptor::HeapMode)","symbolLocation":580,"imageIndex":16},{"imageOffset":138052,"symbol":"AG::(anonymous namespace)::TypeDescriptorCache::drain_queue(void*)","symbolLocation":348,"imageIndex":16},{"imageOffset":17384,"symbol":"_dispatch_client_callout","symbolLocation":20,"imageIndex":23},{"imageOffset":90240,"symbol":"_dispatch_root_queue_drain","symbolLocation":864,"imageIndex":23},{"imageOffset":91832,"symbol":"_dispatch_worker_thread2","symbolLocation":156,"imageIndex":23},{"imageOffset":12240,"symbol":"_pthread_wqthread","symbolLocation":228,"imageIndex":11},{"imageOffset":7464,"symbol":"start_wqthread","symbolLocation":8,"imageIndex":11}]},{"id":66105,"name":"caulk.messenger.shared:17","threadState":{"x":[{"value":14},{"value":105553153015834},{"value":0},{"value":6095532138},{"value":105553153015808},{"value":25},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":8827531504},{"value":0},{"value":105553141602640},{"value":105553141602640},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7086421540},"cpsr":{"value":2147487744},"fp":{"value":6095531904},"sp":{"value":6095531872},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647536},"far":{"value":0}},"frames":[{"imageOffset":4464,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":9764,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":212,"imageIndex":24},{"imageOffset":9432,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":36,"imageIndex":24},{"imageOffset":8664,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":24},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66106,"name":"caulk.messenger.shared:high","threadState":{"x":[{"value":14},{"value":19715},{"value":19715},{"value":17},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":1},{"value":105553163627304},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":8827531504},{"value":0},{"value":105553141600976},{"value":105553141600976},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7086421540},"cpsr":{"value":2147487744},"fp":{"value":6096105344},"sp":{"value":6096105312},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647536},"far":{"value":0}},"frames":[{"imageOffset":4464,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":9764,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":212,"imageIndex":24},{"imageOffset":9432,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":36,"imageIndex":24},{"imageOffset":8664,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":24},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66132,"name":"caulk::deferred_logger","threadState":{"x":[{"value":14},{"value":105553123794647},{"value":0},{"value":6096679015},{"value":105553123794624},{"value":22},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":8827531504},{"value":0},{"value":105553143712888},{"value":105553143712888},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7086421540},"cpsr":{"value":2147487744},"fp":{"value":6096678784},"sp":{"value":6096678752},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647536},"far":{"value":0}},"frames":[{"imageOffset":4464,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":9764,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":212,"imageIndex":24},{"imageOffset":9432,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":36,"imageIndex":24},{"imageOffset":8664,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":24},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66149,"frames":[{"imageOffset":7456,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":11}],"threadState":{"x":[{"value":6097252352},{"value":50435},{"value":6096715776},{"value":6097251200},{"value":5193732},{"value":1},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6097251184},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912892192},"far":{"value":0}}},{"id":66201,"frames":[{"imageOffset":7456,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":11}],"threadState":{"x":[{"value":6098399232},{"value":37643},{"value":6097862656},{"value":0},{"value":409604},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6098399232},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912892192},"far":{"value":0}}},{"id":66219,"frames":[{"imageOffset":7456,"symbol":"start_wqthread","symbolLocation":0,"imageIndex":11}],"threadState":{"x":[{"value":6098972672},{"value":0},{"value":6098436096},{"value":0},{"value":278532},{"value":18446744073709551615},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":0},"cpsr":{"value":4096},"fp":{"value":0},"sp":{"value":6098972672},"esr":{"value":0,"description":" Address size fault"},"pc":{"value":6912892192},"far":{"value":0}}},{"id":66224,"name":"com.apple.audio.toolbox.AUScheduledParameterRefresher","threadState":{"x":[{"value":14},{"value":105553172932854},{"value":0},{"value":6099546246},{"value":105553172932800},{"value":53},{"value":0},{"value":0},{"value":0},{"value":4294967295},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":18446744073709551580},{"value":8827531504},{"value":0},{"value":105553143713336},{"value":105553143713336},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":7086421540},"cpsr":{"value":2147487744},"fp":{"value":6099545984},"sp":{"value":6099545952},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647536},"far":{"value":0}},"frames":[{"imageOffset":4464,"symbol":"semaphore_wait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":9764,"symbol":"caulk::semaphore::timed_wait(double)","symbolLocation":212,"imageIndex":24},{"imageOffset":9432,"symbol":"caulk::concurrent::details::worker_thread::run()","symbolLocation":36,"imageIndex":24},{"imageOffset":8664,"symbol":"void* caulk::thread_proxy<std::__1::tuple<caulk::thread::attributes, void (caulk::concurrent::details::worker_thread::*)(), std::__1::tuple<caulk::concurrent::details::worker_thread*>>>(void*)","symbolLocation":96,"imageIndex":24},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66227,"name":"AQConverterThread","threadState":{"x":[{"value":260},{"value":0},{"value":1280},{"value":0},{"value":0},{"value":160},{"value":0},{"value":0},{"value":6100119128},{"value":0},{"value":4779536736},{"value":2},{"value":0},{"value":0},{"value":0},{"value":0},{"value":305},{"value":8827541728},{"value":0},{"value":4779536712},{"value":4779536776},{"value":6100119776},{"value":0},{"value":0},{"value":1280},{"value":1281},{"value":1536},{"value":2},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6912914780},"cpsr":{"value":1610616832},"fp":{"value":6100119248},"sp":{"value":6100119104},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912661996},"far":{"value":0}},"frames":[{"imageOffset":18924,"symbol":"__psynch_cvwait","symbolLocation":8,"imageIndex":10},{"imageOffset":30044,"symbol":"_pthread_cond_wait","symbolLocation":1228,"imageIndex":11},{"imageOffset":199908,"symbol":"CADeprecated::CAGuard::Wait()","symbolLocation":76,"imageIndex":25},{"imageOffset":167800,"symbol":"AQConverterManager::AQConverterThread::ConverterThreadEntry(void*)","symbolLocation":572,"imageIndex":26},{"imageOffset":53844,"symbol":"CADeprecated::CAPThread::Entry(CADeprecated::CAPThread*)","symbolLocation":92,"imageIndex":25},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66235,"name":"com.apple.NSURLConnectionLoader","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":556365768556544},{"value":0},{"value":556365768556544},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":129539},{"value":0},{"value":1},{"value":129539},{"value":2045214},{"value":0},{"value":8796093022208},{"value":18446744073709551569},{"value":8827525888},{"value":0},{"value":4294967295},{"value":2},{"value":556365768556544},{"value":0},{"value":556365768556544},{"value":6100688216},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6912723748},"cpsr":{"value":4096},"fp":{"value":6100688064},"sp":{"value":6100687984},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647668},"far":{"value":0}},"frames":[{"imageOffset":4596,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":80676,"symbol":"mach_msg2_internal","symbolLocation":80,"imageIndex":10},{"imageOffset":40500,"symbol":"mach_msg_overwrite","symbolLocation":476,"imageIndex":10},{"imageOffset":5496,"symbol":"mach_msg","symbolLocation":24,"imageIndex":10},{"imageOffset":517760,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":17},{"imageOffset":511812,"symbol":"__CFRunLoopRun","symbolLocation":1208,"imageIndex":17},{"imageOffset":508980,"symbol":"CFRunLoopRunSpecific","symbolLocation":608,"imageIndex":17},{"imageOffset":2488856,"imageIndex":27},{"imageOffset":348032,"symbol":"__NSThread__start__","symbolLocation":716,"imageIndex":28},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":66237,"name":"com.apple.NSEventThread","threadState":{"x":[{"value":268451845},{"value":21592279046},{"value":8589934592},{"value":393638047645696},{"value":0},{"value":393638047645696},{"value":2},{"value":4294967295},{"value":18446744073709550527},{"value":91651},{"value":0},{"value":1},{"value":91651},{"value":8221902},{"value":0},{"value":0},{"value":18446744073709551569},{"value":8827525888},{"value":0},{"value":4294967295},{"value":2},{"value":393638047645696},{"value":0},{"value":393638047645696},{"value":6101262440},{"value":8589934592},{"value":21592279046},{"value":21592279046},{"value":4412409862}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6912723748},"cpsr":{"value":4096},"fp":{"value":6101262288},"sp":{"value":6101262208},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647668},"far":{"value":0}},"frames":[{"imageOffset":4596,"symbol":"mach_msg2_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":80676,"symbol":"mach_msg2_internal","symbolLocation":80,"imageIndex":10},{"imageOffset":40500,"symbol":"mach_msg_overwrite","symbolLocation":476,"imageIndex":10},{"imageOffset":5496,"symbol":"mach_msg","symbolLocation":24,"imageIndex":10},{"imageOffset":517760,"symbol":"__CFRunLoopServiceMachPort","symbolLocation":160,"imageIndex":17},{"imageOffset":511812,"symbol":"__CFRunLoopRun","symbolLocation":1208,"imageIndex":17},{"imageOffset":508980,"symbol":"CFRunLoopRunSpecific","symbolLocation":608,"imageIndex":17},{"imageOffset":1458568,"symbol":"_NSEventThread","symbolLocation":144,"imageIndex":19},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":67065,"name":"com.apple.coremedia.sharedRootQueue.48","threadState":{"x":[{"value":14},{"value":4294967115611373572},{"value":999999958},{"value":68719460488},{"value":8655895528,"symbolLocation":40,"symbol":"_OS_dispatch_queue_serial_vtable"},{"value":9792},{"value":0},{"value":0},{"value":999999958},{"value":12297829382473034411},{"value":13835058055282163714},{"value":80000000},{"value":105553130022712},{"value":274877906945},{"value":9005618706776065},{"value":9005618706776065},{"value":18446744073709551578},{"value":8735287152},{"value":0},{"value":108893087452},{"value":4780152480},{"value":1000000000},{"value":6094958816},{"value":0},{"value":0},{"value":18446744071427850239},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6911142400},"cpsr":{"value":2147487744},"fp":{"value":6094958400},"sp":{"value":6094958368},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647560},"far":{"value":0}},"frames":[{"imageOffset":4488,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":18944,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":23},{"imageOffset":20476,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":23},{"imageOffset":89212,"symbol":"_dispatch_worker_thread","symbolLocation":328,"imageIndex":23},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"id":67066,"name":"com.apple.coremedia.sharedRootQueue.49","threadState":{"x":[{"value":14},{"value":4294967115611373572},{"value":999999958},{"value":68719460488},{"value":8753556272},{"value":15104},{"value":105553173857280},{"value":6097822040},{"value":999999958},{"value":12297829382473034411},{"value":13835058055282163714},{"value":80000000},{"value":105553130259640},{"value":2045},{"value":2388676618},{"value":10},{"value":18446744073709551578},{"value":8735287152},{"value":0},{"value":108893088507},{"value":4780330096},{"value":1000000000},{"value":6097826016},{"value":0},{"value":0},{"value":18446744071427850239},{"value":0},{"value":0},{"value":0}],"flavor":"ARM_THREAD_STATE64","lr":{"value":6911142400},"cpsr":{"value":2147487744},"fp":{"value":6097825600},"sp":{"value":6097825568},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":6912647560},"far":{"value":0}},"frames":[{"imageOffset":4488,"symbol":"semaphore_timedwait_trap","symbolLocation":8,"imageIndex":10},{"imageOffset":18944,"symbol":"_dispatch_sema4_timedwait","symbolLocation":64,"imageIndex":23},{"imageOffset":20476,"symbol":"_dispatch_semaphore_wait_slow","symbolLocation":76,"imageIndex":23},{"imageOffset":89212,"symbol":"_dispatch_worker_thread","symbolLocation":328,"imageIndex":23},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]},{"threadState":{"x":[{"value":0},{"value":8529598074,"objc-selector":"countByEnumeratingWithState:objects:count:"},{"value":6101835472},{"value":6101835712},{"value":16},{"value":0},{"value":0},{"value":1027},{"value":15999860347893645547},{"value":15999860347893645547},{"value":12391062674},{"value":63},{"value":58},{"value":4783081360},{"value":72057602693910249,"symbolLocation":72057594037927937,"symbol":"OBJC_CLASS_$___NSArrayI_Transfer"},{"value":8655982312,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArrayI_Transfer"},{"value":8655982312,"symbolLocation":0,"symbol":"OBJC_CLASS_$___NSArrayI_Transfer"},{"value":10611043678952356640,"symbolLocation":10611043672038309888,"symbol":"-[__NSArrayI_Transfer countByEnumeratingWithState:objects:count:]"},{"value":0},{"value":0},{"value":1},{"value":0},{"value":8638873600,"symbolLocation":8,"symbol":"gAVSynchronizedLayerTrace"},{"value":105553152157408},{"value":8762264688},{"value":8762299568},{"value":8638873600,"symbolLocation":8,"symbol":"gAVSynchronizedLayerTrace"},{"value":105553176184000},{"value":8762264688}],"flavor":"ARM_THREAD_STATE64","lr":{"value":17174195711276874164},"cpsr":{"value":1610616832},"fp":{"value":6101835936},"sp":{"value":6101835408},"esr":{"value":1442840704,"description":" Address size fault"},"pc":{"value":7276198332},"far":{"value":0}},"id":67067,"name":"com.apple.coremedia.sharedRootQueue.47","queue":"CommonURLAssetNotificationQueue","frames":[{"imageOffset":924092,"symbol":"-[AVFigAssetInspectorLoader _invokeCompletionHandlerForLoadingBatches:]","symbolLocation":868,"imageIndex":29},{"imageOffset":914796,"symbol":"handleFigAssetLoadingNotification","symbolLocation":564,"imageIndex":29},{"imageOffset":471344,"symbol":"__CFNOTIFICATIONCENTER_IS_CALLING_OUT_TO_AN_OBSERVER__","symbolLocation":128,"imageIndex":17},{"imageOffset":1078232,"symbol":"___CFXRegistrationPost_block_invoke","symbolLocation":88,"imageIndex":17},{"imageOffset":1078048,"symbol":"_CFXRegistrationPost","symbolLocation":440,"imageIndex":17},{"imageOffset":267896,"symbol":"_CFXNotificationPost","symbolLocation":768,"imageIndex":17},{"imageOffset":471584,"symbol":"CFNotificationCenterPostNotificationWithOptions","symbolLocation":136,"imageIndex":17},{"imageOffset":34628,"symbol":"CMNotificationCenterPostNotification","symbolLocation":128,"imageIndex":30},{"imageOffset":55720,"symbol":"figDeferredPostNotification","symbolLocation":40,"imageIndex":30},{"imageOffset":17384,"symbol":"_dispatch_client_callout","symbolLocation":20,"imageIndex":23},{"imageOffset":47636,"symbol":"_dispatch_lane_serial_drain","symbolLocation":748,"imageIndex":23},{"imageOffset":50552,"symbol":"_dispatch_lane_invoke","symbolLocation":432,"imageIndex":23},{"imageOffset":89768,"symbol":"_dispatch_root_queue_drain","symbolLocation":392,"imageIndex":23},{"imageOffset":89144,"symbol":"_dispatch_worker_thread","symbolLocation":260,"imageIndex":23},{"imageOffset":28564,"symbol":"_pthread_start","symbolLocation":136,"imageIndex":11},{"imageOffset":7476,"symbol":"thread_start","symbolLocation":8,"imageIndex":11}]}],
  "usedImages" : [
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4771430400,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.icloud.drive.fileprovider.override",
    "size" : 16384,
    "uuid" : "db39a641-8c34-385d-8faf-37cb3dcfc89e",
    "path" : "\/System\/Library\/Frameworks\/FileProvider.framework\/OverrideBundles\/iCloudDriveFileProviderOverride.bundle\/Contents\/MacOS\/iCloudDriveFileProviderOverride",
    "name" : "iCloudDriveFileProviderOverride",
    "CFBundleVersion" : "2720.120.29"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4772364288,
    "CFBundleShortVersionString" : "14.5",
    "CFBundleIdentifier" : "com.apple.findersync.fileprovideroverride.FinderSyncCollaborationFileProviderOverride",
    "size" : 131072,
    "uuid" : "45b63a1f-97c2-3047-9430-120757ec26f6",
    "path" : "\/System\/Library\/Frameworks\/FileProvider.framework\/OverrideBundles\/FinderSyncCollaborationFileProviderOverride.bundle\/Contents\/MacOS\/FinderSyncCollaborationFileProviderOverride",
    "name" : "FinderSyncCollaborationFileProviderOverride",
    "CFBundleVersion" : "1632.5.3"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4771725312,
    "CFBundleShortVersionString" : "1835.120.53",
    "CFBundleIdentifier" : "com.apple.FileProviderOverride",
    "size" : 32768,
    "uuid" : "48c78787-aebf-3b9c-8300-2b20ba87b0a4",
    "path" : "\/System\/Library\/Frameworks\/FileProvider.framework\/OverrideBundles\/FileProviderOverride.bundle\/Contents\/MacOS\/FileProviderOverride",
    "name" : "FileProviderOverride",
    "CFBundleVersion" : "1835.120.53"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 5478563840,
    "CFBundleShortVersionString" : "3.0",
    "CFBundleIdentifier" : "com.apple.security.csparser",
    "size" : 131072,
    "uuid" : "5b38c00e-20a2-3dd5-b582-3d7bf058f0ba",
    "path" : "\/System\/Library\/Frameworks\/Security.framework\/Versions\/A\/PlugIns\/csparser.bundle\/Contents\/MacOS\/csparser",
    "name" : "csparser",
    "CFBundleVersion" : "61123.121.1"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4758437888,
    "CFBundleShortVersionString" : "7.0",
    "CFBundleIdentifier" : "com.apple.audio.codecs.Components",
    "size" : 9306112,
    "uuid" : "10dc413b-3923-3f80-8a3d-35aacaaa801e",
    "path" : "\/System\/Library\/Components\/AudioCodecs.component\/Contents\/MacOS\/AudioCodecs",
    "name" : "AudioCodecs",
    "CFBundleVersion" : "7.0"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4426743808,
    "CFBundleShortVersionString" : "1.14",
    "CFBundleIdentifier" : "com.apple.audio.units.Components",
    "size" : 1277952,
    "uuid" : "fd93a3bc-5142-33ea-88bd-c2258c5a032d",
    "path" : "\/System\/Library\/Components\/CoreAudio.component\/Contents\/MacOS\/CoreAudio",
    "name" : "CoreAudio",
    "CFBundleVersion" : "1.14"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 4382900224,
    "size" : 49152,
    "uuid" : "9381bd6d-84a5-3c72-b3b8-88428afa4782",
    "path" : "\/usr\/lib\/libobjc-trampolines.dylib",
    "name" : "libobjc-trampolines.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4386996224,
    "CFBundleShortVersionString" : "2.7.0",
    "CFBundleIdentifier" : "org.sparkle-project.Sparkle",
    "size" : 278528,
    "uuid" : "e1818fcc-1225-3d7d-ab35-30d26f536a6a",
    "path" : "\/Applications\/Clio.app\/Contents\/Frameworks\/Sparkle.framework\/Versions\/B\/Sparkle",
    "name" : "Sparkle",
    "CFBundleVersion" : "2044"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4391632896,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "org.ggml.whisper",
    "size" : 1261568,
    "uuid" : "a954dee5-970f-3cd5-ad33-6c3c0b325b03",
    "path" : "\/Applications\/Clio.app\/Contents\/Frameworks\/whisper.framework\/Versions\/A\/whisper",
    "name" : "whisper",
    "CFBundleVersion" : "1"
  },
  {
    "source" : "P",
    "arch" : "arm64",
    "base" : 4373626880,
    "CFBundleShortVersionString" : "1.0.9",
    "CFBundleIdentifier" : "com.cliovoice.clio",
    "size" : 6504448,
    "uuid" : "5bceaace-2fbf-3dcc-b919-3b1fd849e195",
    "path" : "\/Applications\/Clio.app\/Contents\/MacOS\/Clio",
    "name" : "Clio",
    "CFBundleVersion" : "109"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6912643072,
    "size" : 241660,
    "uuid" : "9b8b53f9-e2b6-36df-98e9-28d8fca732f2",
    "path" : "\/usr\/lib\/system\/libsystem_kernel.dylib",
    "name" : "libsystem_kernel.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6912884736,
    "size" : 53248,
    "uuid" : "386b0fc1-7873-3328-8e71-43269fd1b2c7",
    "path" : "\/usr\/lib\/system\/libsystem_pthread.dylib",
    "name" : "libsystem_pthread.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6911430656,
    "size" : 520184,
    "uuid" : "05b44e93-dffc-3bd8-90ab-fd97cb73f171",
    "path" : "\/usr\/lib\/system\/libsystem_c.dylib",
    "name" : "libsystem_c.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7177977856,
    "size" : 5627904,
    "uuid" : "c2fd0f69-d72c-37a5-938e-1bd710c88431",
    "path" : "\/usr\/lib\/swift\/libswiftCore.dylib",
    "name" : "libswiftCore.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 9436049408,
    "size" : 32754,
    "uuid" : "db7863c4-ea47-301b-ab7e-01f6476f9413",
    "path" : "\/System\/Library\/Frameworks\/_AVKit_SwiftUI.framework\/Versions\/A\/_AVKit_SwiftUI",
    "name" : "_AVKit_SwiftUI"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7644233728,
    "CFBundleShortVersionString" : "5.5.8",
    "CFBundleIdentifier" : "com.apple.SwiftUI",
    "size" : 30294016,
    "uuid" : "71c9cc70-1a85-396b-a92a-c893fe8bd541",
    "path" : "\/System\/Library\/Frameworks\/SwiftUI.framework\/Versions\/A\/SwiftUI",
    "name" : "SwiftUI",
    "CFBundleVersion" : "5.5.8"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7674527744,
    "CFBundleShortVersionString" : "5.4.16",
    "CFBundleIdentifier" : "com.apple.AttributeGraph",
    "size" : 282624,
    "uuid" : "fffe46a2-2d66-3719-b6ca-69d9760ce96f",
    "path" : "\/System\/Library\/PrivateFrameworks\/AttributeGraph.framework\/Versions\/A\/AttributeGraph",
    "name" : "AttributeGraph",
    "CFBundleVersion" : "5.4.16"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6913310720,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.CoreFoundation",
    "size" : 5083136,
    "uuid" : "84b539d5-22c9-3f8c-84c8-903e9c7b8d29",
    "path" : "\/System\/Library\/Frameworks\/CoreFoundation.framework\/Versions\/A\/CoreFoundation",
    "name" : "CoreFoundation",
    "CFBundleVersion" : "2503.1"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7089393664,
    "CFBundleShortVersionString" : "2.1.1",
    "CFBundleIdentifier" : "com.apple.HIToolbox",
    "size" : 2899968,
    "uuid" : "7db6c397-563f-3756-908c-e25b019a1848",
    "path" : "\/System\/Library\/Frameworks\/Carbon.framework\/Versions\/A\/Frameworks\/HIToolbox.framework\/Versions\/A\/HIToolbox",
    "name" : "HIToolbox"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6972694528,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.AppKit",
    "size" : 20172800,
    "uuid" : "61f710be-9132-3cc2-883d-066365fba1ad",
    "path" : "\/System\/Library\/Frameworks\/AppKit.framework\/Versions\/C\/AppKit",
    "name" : "AppKit",
    "CFBundleVersion" : "2487.60.105"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6909181952,
    "size" : 559640,
    "uuid" : "37bbc384-0755-31c7-a808-0ed49e44dd8e",
    "path" : "\/usr\/lib\/dyld",
    "name" : "dyld"
  },
  {
    "size" : 0,
    "source" : "A",
    "base" : 0,
    "uuid" : "00000000-0000-0000-0000-000000000000"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6913093632,
    "size" : 32744,
    "uuid" : "d5bbfc31-d52a-37d6-a41b-48638113ad4c",
    "path" : "\/usr\/lib\/system\/libsystem_platform.dylib",
    "name" : "libsystem_platform.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6911123456,
    "size" : 294912,
    "uuid" : "502762ee-7aa7-306c-9dbd-88981a86bb78",
    "path" : "\/usr\/lib\/system\/libdispatch.dylib",
    "name" : "libdispatch.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7086411776,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.audio.caulk",
    "size" : 172032,
    "uuid" : "f2da6e2e-b5a0-3ce7-97f5-7d2141a3ec32",
    "path" : "\/System\/Library\/PrivateFrameworks\/caulk.framework\/Versions\/A\/caulk",
    "name" : "caulk"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7164801024,
    "size" : 233472,
    "uuid" : "cf1cffc5-2961-3894-b753-80ac364540d5",
    "path" : "\/usr\/lib\/libAudioToolboxUtility.dylib",
    "name" : "libAudioToolboxUtility.dylib"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7184588800,
    "CFBundleShortVersionString" : "1.14",
    "CFBundleIdentifier" : "com.apple.audio.toolbox.AudioToolbox",
    "size" : 1572864,
    "uuid" : "b1800481-82d6-39e7-9500-8c14e3d786c9",
    "path" : "\/System\/Library\/Frameworks\/AudioToolbox.framework\/Versions\/A\/AudioToolbox",
    "name" : "AudioToolbox",
    "CFBundleVersion" : "1.14"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7000051712,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.CFNetwork",
    "size" : 4014080,
    "uuid" : "0af09533-3214-3182-a742-0c04a20f38d1",
    "path" : "\/System\/Library\/Frameworks\/CFNetwork.framework\/Versions\/A\/CFNetwork",
    "name" : "CFNetwork",
    "CFBundleVersion" : "1496.0.7"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 6931484672,
    "CFBundleShortVersionString" : "6.9",
    "CFBundleIdentifier" : "com.apple.Foundation",
    "size" : 12967936,
    "uuid" : "99e0292d-7873-3968-9c9c-5955638689a5",
    "path" : "\/System\/Library\/Frameworks\/Foundation.framework\/Versions\/C\/Foundation",
    "name" : "Foundation",
    "CFBundleVersion" : "2503.1"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7275274240,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.AVFCore",
    "size" : 2408448,
    "uuid" : "2eda8725-a1c6-3a86-9276-07c1c9626621",
    "path" : "\/System\/Library\/PrivateFrameworks\/AVFCore.framework\/Versions\/A\/AVFCore",
    "name" : "AVFCore",
    "CFBundleVersion" : "2240.7.2"
  },
  {
    "source" : "P",
    "arch" : "arm64e",
    "base" : 7086583808,
    "CFBundleShortVersionString" : "1.0",
    "CFBundleIdentifier" : "com.apple.CoreMedia",
    "size" : 1347584,
    "uuid" : "560bc822-f6a0-3d59-82e3-dc919489b341",
    "path" : "\/System\/Library\/Frameworks\/CoreMedia.framework\/Versions\/A\/CoreMedia",
    "name" : "CoreMedia",
    "CFBundleVersion" : "3110.8.2"
  }
],
  "sharedCache" : {
  "base" : 6908428288,
  "size" : 4220698624,
  "uuid" : "3406ad1b-2469-30eb-9863-5dce861e6dea"
},
  "vmSummary" : "ReadOnly portion of Libraries: Total=1.4G resident=0K(0%) swapped_out_or_unallocated=1.4G(100%)\nWritable regions: Total=1.8G written=0K(0%) resident=0K(0%) swapped_out=0K(0%) unallocated=1.8G(100%)\n\n                                VIRTUAL   REGION \nREGION TYPE                        SIZE    COUNT (non-coalesced) \n===========                     =======  ======= \nAccelerate framework               128K        1 \nActivity Tracing                   256K        1 \nAttributeGraph Data               1024K        1 \nCG image                           144K        5 \nColorSync                          592K       29 \nCoreAnimation                     20.8M      101 \nCoreData Object IDs               4112K        2 \nCoreGraphics                        32K        2 \nCoreUI image data                 1456K       10 \nFoundation                          16K        1 \nKernel Alloc Once                   32K        1 \nMALLOC                             1.7G       87 \nMALLOC guard page                  480K       30 \nMALLOC_LARGE (reserved)           26.4M        1         reserved VM address space (unallocated)\nSQLite page cache                  512K        4 \nSTACK GUARD                       56.2M       16 \nStack                             16.0M       16 \nVM_ALLOCATE                       15.1M       38 \n__AUTH                            3384K      574 \n__AUTH_CONST                      40.3M      823 \n__CTF                               824        1 \n__DATA                            18.9M      817 \n__DATA_CONST                      41.7M      841 \n__DATA_DIRTY                      2853K      316 \n__FONT_DATA                          4K        1 \n__INFO_FILTER                         8        1 \n__LINKEDIT                       535.5M       11 \n__OBJC_RO                         71.9M        1 \n__OBJC_RW                         2199K        1 \n__TEXT                           875.7M      861 \ndyld private memory                272K        2 \nlibnetwork                         128K        8 \nmapped file                      306.3M       49 \nshared memory                     1872K       14 \n===========                     =======  ======= \nTOTAL                              3.7G     4667 \nTOTAL, minus reserved VM space     3.7G     4667 \n",
  "legacyInfo" : {
  "threadTriggered" : {
    "queue" : "com.apple.main-thread"
  }
},
  "logWritingSignature" : "72f19f082acfe49a7e011e97acffd8400cd75dde",
  "trialInfo" : {
  "rollouts" : [
    {
      "rolloutId" : "645eb1d0417dab722a215927",
      "factorPackIds" : {

      },
      "deploymentId" : 240000005
    },
    {
      "rolloutId" : "64628732bf2f5257dedc8988",
      "factorPackIds" : {

      },
      "deploymentId" : 240000001
    }
  ],
  "experiments" : [

  ]
}
}

Model: Mac15,3, BootROM 10151.121.1, proc 8:4:4 processors, 16 GB, SMC 
Graphics: Apple M3, Apple M3, Built-In
Display: Color LCD, 3024 x 1964 Retina, Main, MirrorOff, Online
Memory Module: LPDDR5, Hynix
AirPort: spairport_wireless_card_type_wifi (0x14E4, 0x4388), wl0: Apr  4 2024 20:57:11 version 23.30.58.0.41.51.138 FWID 01-baea9d27
AirPort: 
Bluetooth: Version (null), 0 services, 0 devices, 0 incoming serial ports
Network Service: Wi-Fi, AirPort, en0
USB Device: USB31Bus
USB Device: USB31Bus
Thunderbolt Bus: MacBook Pro, Apple Inc.
Thunderbolt Bus: MacBook Pro, Apple Inc.
