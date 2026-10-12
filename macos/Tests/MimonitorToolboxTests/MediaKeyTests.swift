#if canImport(Cocoa)
import XCTest
@testable import MimonitorToolbox

/// 硬件亮度键走 NX_SYSDEFINED，事件里的 data1 需要手动拆位。
/// 拆错的话表现是"按 F1/F2 完全没反应"，所以这里锁住解析结果。
final class MediaKeyTests: XCTestCase {
    private func data1(keyType: Int32, down: Bool) -> Int {
        (Int(keyType) << 16) | (down ? 0x0A00 : 0x0B00)
    }

    func testBrightnessUpKeyDown() {
        let parsed = HotkeyManager.parseMediaKey(data1: data1(keyType: 2, down: true))
        XCTAssertEqual(parsed.keyType, HotkeyManager.keyTypeBrightnessUp)
        XCTAssertTrue(parsed.isDown)
    }

    func testBrightnessDownKeyDown() {
        let parsed = HotkeyManager.parseMediaKey(data1: data1(keyType: 3, down: true))
        XCTAssertEqual(parsed.keyType, HotkeyManager.keyTypeBrightnessDown)
        XCTAssertTrue(parsed.isDown)
    }

    func testKeyUpIsNotTreatedAsPress() {
        let parsed = HotkeyManager.parseMediaKey(data1: data1(keyType: 2, down: false))
        XCTAssertEqual(parsed.keyType, HotkeyManager.keyTypeBrightnessUp)
        XCTAssertFalse(parsed.isDown)
    }

    /// 其他媒体键（音量、播放…）必须能区分出来，不能误吞。
    func testOtherMediaKeyType() {
        let parsed = HotkeyManager.parseMediaKey(data1: data1(keyType: 0, down: true))
        XCTAssertEqual(parsed.keyType, 0)
        XCTAssertTrue(parsed.isDown)
    }

    // MARK: 亮度键以普通 keyDown 到达（keyCode 144/145）

    func testKeyDownBrightnessUp() {
        XCTAssertEqual(HotkeyManager.mediaKeyType(forKeyCode: 144),
                       HotkeyManager.keyTypeBrightnessUp)
    }

    func testKeyDownBrightnessDown() {
        XCTAssertEqual(HotkeyManager.mediaKeyType(forKeyCode: 145),
                       HotkeyManager.keyTypeBrightnessDown)
    }

    func testKeyDownNonBrightnessKeyIsIgnored() {
        // F1 / F2（标准功能键）走另一条裸键绑定，不在这里映射
        XCTAssertNil(HotkeyManager.mediaKeyType(forKeyCode: 122))
        XCTAssertNil(HotkeyManager.mediaKeyType(forKeyCode: 120))
        XCTAssertNil(HotkeyManager.mediaKeyType(forKeyCode: 0))
    }
}
#endif
