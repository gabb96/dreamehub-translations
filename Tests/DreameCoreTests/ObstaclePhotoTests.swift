import XCTest
import Security
@testable import DreameCore

final class ObstaclePhotoTests:XCTestCase {
    func testOnlyImageMagicAccepted() {
        XCTAssertEqual(ObstaclePhotoService.contentType(Data([0xff,0xd8,0xff,0x00])),"image/jpeg")
        XCTAssertEqual(ObstaclePhotoService.contentType(Data([0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a])),"image/png")
        XCTAssertNil(ObstaclePhotoService.contentType(Data("{\"error\":1}".utf8)))
    }
    func testRSASPKIAndOAEPCompatibility() throws {
        let attributes:[String:Any]=[kSecAttrKeyType as String:kSecAttrKeyTypeRSA,kSecAttrKeySizeInBits as String:1024]
        var error:Unmanaged<CFError>?
        let privateKey=try XCTUnwrap(SecKeyCreateRandomKey(attributes as CFDictionary,&error))
        let publicKey=try XCTUnwrap(SecKeyCopyPublicKey(privateKey))
        let pkcs1=try XCTUnwrap(SecKeyCopyExternalRepresentation(publicKey,&error) as Data?)
        let spki=ObstaclePhotoService.subjectPublicKeyInfo(pkcs1)
        let pubAttributes:[String:Any]=[kSecAttrKeyType as String:kSecAttrKeyTypeRSA,kSecAttrKeyClass as String:kSecAttrKeyClassPublic,kSecAttrKeySizeInBits as String:1024]
        let imported=try XCTUnwrap(SecKeyCreateWithData(spki as CFData,pubAttributes as CFDictionary,&error))
        let plain=Data("synthetic-photo-key".utf8)
        let encrypted=try XCTUnwrap(SecKeyCreateEncryptedData(imported,.rsaEncryptionOAEPSHA1,plain as CFData,&error))
        let decrypted=try XCTUnwrap(SecKeyCreateDecryptedData(privateKey,.rsaEncryptionOAEPSHA1,encrypted,&error) as Data?)
        XCTAssertEqual(plain,decrypted)
    }
}
