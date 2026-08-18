import XCTest

@testable import ImageExtract

class ImageDecoderTests: XCTestCase {

    func testZeroByteData() {
        XCTAssertEqual(JPGDecoder().getSize(Data()), CGSize.zero)
        XCTAssertEqual(PNGDecoder().getSize(Data()), CGSize.zero)
        XCTAssertEqual(GIFDecoder().getSize(Data()), CGSize.zero)
        XCTAssertEqual(BMPDecoder().getSize(Data()), CGSize.zero)
//        XCTAssertEqual(TIFFDecoder.decodeSize(Data()), CGSize.zero) /* TODO: Support TIFF (low priority) */
        XCTAssertEqual(WEBPDecoder().getSize(Data()), CGSize.zero)
    }

    /**
     Builds a minimal WebP byte sequence: RIFF header, chunk fourcc, and payload.
     The RIFF and chunk size fields are not read by the decoder and are left zero.
     */
    private func webp(chunk: String, payload: [UInt8], padTo length: Int = 30) -> Data {
        var bytes: [UInt8] = Array("RIFF".utf8) + [0, 0, 0, 0] + Array("WEBP".utf8)
        bytes += Array(chunk.utf8) + [0, 0, 0, 0]
        bytes += payload
        if bytes.count < length { bytes += [UInt8](repeating: 0, count: length - bytes.count) }
        return Data(bytes)
    }

    func testWebPLossySizeIgnoresScalingBits() {
        /* VP8 bitstream: 3-byte frame tag, 3-byte start code,
           then 14-bit width and height each followed by a 2-bit upscale flag */
        let data: Data = webp(chunk: "VP8 ", payload: [0x00, 0x00, 0x00, 0x9D, 0x01, 0x2A, 0x26, 0x42, 0x70, 0x41])
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize(width: 550, height: 368))
    }

    func testWebPLosslessSize() {
        /* VP8L bitstream: 1-byte signature 0x2F,
           then 14-bit (width - 1) and (height - 1) packed LSB first */
        let data: Data = webp(chunk: "VP8L", payload: [0x2F, 0x1F, 0xC3, 0x95, 0x00])
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize(width: 800, height: 600))
    }

    func testWebPExtendedSize() {
        /* VP8X chunk: 4 bytes of flags and reserved space,
           then 24-bit (width - 1) and (height - 1) */
        let data: Data = webp(chunk: "VP8X", payload: [0x00, 0x00, 0x00, 0x00, 0x2B, 0x01, 0x00, 0xC7, 0x00, 0x00])
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize(width: 300, height: 200))
    }

    func testWebPExtendedSizeWiderThan16Bit() {
        /* A canvas width of 70000 requires the full 24-bit field */
        let data: Data = webp(chunk: "VP8X", payload: [0x00, 0x00, 0x00, 0x00, 0x6F, 0x11, 0x01, 0xC7, 0x00, 0x00])
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize(width: 70000, height: 200))
    }

    func testWebPTruncatedDataReturnsZero() {
        let data: Data = webp(chunk: "VP8X", payload: [0x00, 0x00, 0x00, 0x00], padTo: 0)
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize.zero)
    }

    func testWebPUnknownChunkReturnsZero() {
        let data: Data = webp(chunk: "ANIM", payload: [0x00, 0x00, 0x00, 0x00, 0x2B, 0x01, 0x00, 0xC7, 0x00, 0x00])
        XCTAssertEqual(WEBPDecoder().getSize(data), CGSize.zero)
    }

}
