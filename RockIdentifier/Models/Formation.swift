// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation

struct Formation: Codable {
    let formationType: String
    let environment: String
    let geologicalAge: String?
    let commonLocations: [String]?
    let associatedMinerals: [String]?
    let formationProcess: String
    let additionalInfo: [String: String]?
    
    init(
        formationType: String,
        environment: String,
        geologicalAge: String? = nil,
        commonLocations: [String]? = nil,
        associatedMinerals: [String]? = nil,
        formationProcess: String,
        additionalInfo: [String: String]? = nil
    ) {
        self.formationType = formationType
        self.environment = environment
        self.geologicalAge = geologicalAge
        self.commonLocations = commonLocations
        self.associatedMinerals = associatedMinerals
        self.formationProcess = formationProcess
        self.additionalInfo = additionalInfo
    }
}
