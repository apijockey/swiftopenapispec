////
////  SampleGenerator.swift
////  openapigenerator
////
////  Created by Patric Dubois on 19.12.25.
////
//
//import JSONSchema
//
//protocol SampleBodyGenerator {
//  func sample(for schema: SchemaNode, config: ConverterConfig ) -> SchemaNode
//}
//
//
//public final class SampleGenerator {
//    public struct Options {
//        public var maxDepth: Int = 2
//        public var preferDefaults: Bool = true
//        public init() {
//            self.maxDepth = 2
//            self.preferDefaults = true
//        }
//    }
//
//    public init(options: Options = .init()) { self.options = options }
//    private let options: Options
//
//    func generateSample(from schema: SchemaNode) -> SchemaNode{
//        switch schema {
//        case .object(let obj):
//            var result: [String: SchemaNode] = [:]
//            for key in obj.required {
//                result[key] = generateSample(from: obj.properties[key]!)
//            }
//            return .object(result)
//
//        case .array(let arr):
//            return .array([generateSample(from: arr.items.value)])
//
//        case .string(let s):
//            if let e = s.enumValues?.first { return .string(e) }
//            if let d = s.defaultValue { return .string(d) }
//            return .string("string")
//
//        case .integer(let i):
//            if let e = i.enumValues?.first { return .integer(e) }
//            if let d = i.defaultValue { return .integer(d) }
//            return .integer(i.minimum ?? 0)
//
//        case .boolean:
//            return .bool(true)
//
//        case .null:
//            return .null
//
//        case .oneOf(let schemas),
//             .anyOf(let schemas):
//            return generateSample(from: schemas.first!)
//        case .number(_):
//            
//        case .unsupported(reason: let reason):
//            
//        }
//    }
//
//
//    // sampleString/Integer/Number respektieren pattern/min/max etc.
//}
