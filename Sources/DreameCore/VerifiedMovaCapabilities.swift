import Foundation

/// Narrow protocol encoding evidence, not a general capability/support promise.
/// Upstream DEVICE_INFO audited 2026-10-19: all IDs below have MOP_PAD_LIFTING(64)=1
/// and no WASHLESS_BASE(84). SELF_WASH_BASE_STATUS (4,25) must also be reported live.
/// Source: Tasshack/dreame-vacuum, dreame/const.py + types.py capability.load.
public enum VerifiedMovaCapabilities {
    public static let groupedCleaningModelIDs: Set<String> = [
        "dreame.vacuum.r2427", "dreame.vacuum.r2427a",
        "mova.vacuum.r5732a", "mova.vacuum.r9504a",
        "mova.vacuum.r6710a", "mova.vacuum.r6710g", "mova.vacuum.r6710h", "mova.vacuum.r6710t",
        "mova.vacuum.r67095", "mova.vacuum.r6709a", "mova.vacuum.r6709g", "mova.vacuum.r6709h",
        "mova.vacuum.r2599h", "mova.vacuum.r2599k", "mova.vacuum.r2599u",
        "mova.vacuum.r2475a", "mova.vacuum.r2475h", "mova.vacuum.r2475t", "mova.vacuum.r2587a", "mova.vacuum.r9416d",
        "mova.vacuum.r2519a", "mova.vacuum.r5770", "mova.vacuum.r590q",
        "mova.vacuum.r5977a", "mova.vacuum.r5977c", "mova.vacuum.r5977f", "mova.vacuum.r5977g", "mova.vacuum.r5977h", "mova.vacuum.r5977k", "mova.vacuum.r5977t",
        "mova.vacuum.r5769a", "mova.vacuum.r5769f", "mova.vacuum.r5769g", "mova.vacuum.r5769h", "mova.vacuum.r5769q", "mova.vacuum.r5769t",
        "mova.vacuum.r5770a", "mova.vacuum.r5770g", "mova.vacuum.r5770h", "mova.vacuum.r5770q", "mova.vacuum.r5770t", "mova.vacuum.r590qf",
        "mova.vacuum.r2525a", "mova.vacuum.r2525e", "mova.vacuum.r2525h",
        "mova.vacuum.r2582a", "mova.vacuum.r2582h", "mova.vacuum.r2582c", "mova.vacuum.r2582k",
        "mova.vacuum.r5979a", "mova.vacuum.r5979f", "mova.vacuum.r5979g", "mova.vacuum.r5979h", "mova.vacuum.r5979t",
        "mova.vacuum.r59795", "mova.vacuum.r59796", "mova.vacuum.r59797", "mova.vacuum.r59799", "mova.vacuum.r5979u",
        "mova.vacuum.r5978a", "mova.vacuum.r5978h", "mova.vacuum.r5978q",
        "mova.vacuum.r2430a", "mova.vacuum.r2430u",
        "mova.vacuum.r9540a", "mova.vacuum.r9540h", "mova.vacuum.r9540k", "mova.vacuum.r9540n", "mova.vacuum.r9540u", "mova.vacuum.r9544a",
        "mova.vacuum.r5765h", "mova.vacuum.r5765k", "mova.vacuum.r5765p", "mova.vacuum.r5765q", "mova.vacuum.r5765u",
        "mova.vacuum.r5766h", "mova.vacuum.r5766k", "mova.vacuum.r5766q"
    ]

    public static func supportsGroupedCleaning(model: String, hasSelfWashBase: Bool) -> Bool {
        hasSelfWashBase && groupedCleaningModelIDs.contains(model)
    }
}
