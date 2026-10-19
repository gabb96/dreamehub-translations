import Foundation

/// Display identity only. Catalog membership does not enable a capability or imply live testing.
/// Exact model identifiers: https://dreame-vacuum.tasshack.com/guide/more/supported-devices#mova
public enum ProductCatalog {
    public struct Entry: Equatable, Sendable {
        public let name: String
        public let imagePath: String
        public let modelIDs: [String]
        fileprivate init(_ name: String, _ image: String, _ ids: [String]) {
            self.name = "MOVA " + name
            self.imagePath = "/assets/products/mova/" + image + ".png"
            self.modelIDs = ids
        }
    }

    public static let entries: [Entry] = [
        Entry("E20 Plus", "e20-plus", ["dreame.vacuum.r2459a", "dreame.vacuum.r2459h", "dreame.vacuum.r2459k"]),
        Entry("E30 Ultra", "e30-ultra", ["dreame.vacuum.r2427", "dreame.vacuum.r2427a"]),
        Entry("E40 Ultra", "e40-ultra", ["mova.vacuum.r5732a", "mova.vacuum.r9504a"]),
        Entry("E50 Pro Ultra", "e50-pro-ultra", ["mova.vacuum.r6710a", "mova.vacuum.r6710g", "mova.vacuum.r6710h", "mova.vacuum.r6710t"]),
        Entry("E50 Ultra", "e50-ultra", ["mova.vacuum.r67095", "mova.vacuum.r6709a", "mova.vacuum.r6709g", "mova.vacuum.r6709h"]),
        Entry("M1", "m1", ["dreame.vacuum.r2380"]),
        Entry("MOBIUS 60", "mobius-60", ["mova.vacuum.r2599h", "mova.vacuum.r2599k", "mova.vacuum.r2599u"]),
        Entry("P50 Pro Ultra", "p50-pro-ultra", ["mova.vacuum.r2475a", "mova.vacuum.r2475h", "mova.vacuum.r2475t", "mova.vacuum.r2587a", "mova.vacuum.r9416d"]),
        Entry("P50 Ultra", "p50-ultra", ["mova.vacuum.r2519a"]),
        Entry("P70 Pro Ultra", "p70-pro-ultra", ["mova.vacuum.r5770", "mova.vacuum.r590q", "mova.vacuum.r5977a", "mova.vacuum.r5977c", "mova.vacuum.r5977f", "mova.vacuum.r5977g", "mova.vacuum.r5977h", "mova.vacuum.r5977k", "mova.vacuum.r5977t"]),
        Entry("S10 Plus", "s10-plus", ["dreame.vacuum.r2383a", "dreame.vacuum.r2383k"]),
        Entry("S70 Roller", "s70-roller", ["mova.vacuum.r5769a", "mova.vacuum.r5769f", "mova.vacuum.r5769g", "mova.vacuum.r5769h", "mova.vacuum.r5769q", "mova.vacuum.r5769t"]),
        Entry("S70 Ultra Roller", "s70-ultra-roller", ["mova.vacuum.r5770a", "mova.vacuum.r5770g", "mova.vacuum.r5770h", "mova.vacuum.r5770q", "mova.vacuum.r5770t", "mova.vacuum.r590qf"]),
        Entry("V50 Ultra", "v50-ultra", ["mova.vacuum.r2525a", "mova.vacuum.r2525e", "mova.vacuum.r2525h"]),
        Entry("V50 Ultra Complete", "v50-ultra", ["mova.vacuum.r2582a", "mova.vacuum.r2582h", "mova.vacuum.r2582c", "mova.vacuum.r2582k"]),
        Entry("V70 Ultra Complete", "v70-ultra-complete", ["mova.vacuum.r5979a", "mova.vacuum.r5979f", "mova.vacuum.r5979g", "mova.vacuum.r5979h", "mova.vacuum.r5979t"]),
        Entry("V70 Ultra Complete X", "v70-ultra-complete-x", ["mova.vacuum.r59795", "mova.vacuum.r59796", "mova.vacuum.r59797", "mova.vacuum.r59799", "mova.vacuum.r5979u"]),
        Entry("V70 Ultra Pure", "v70-ultra-pure", ["mova.vacuum.r5978a", "mova.vacuum.r5978h", "mova.vacuum.r5978q"]),
        Entry("Z50 Ultra", "z50-ultra", ["mova.vacuum.r2430a", "mova.vacuum.r2430u"]),
        Entry("Z60 Ultra Roller Complete", "z60-ultra-roller-complete", ["mova.vacuum.r9540a", "mova.vacuum.r9540h", "mova.vacuum.r9540k", "mova.vacuum.r9540n", "mova.vacuum.r9540u"]),
        Entry("Z60 Ultra Roller Standalone", "z60-ultra-roller-standalone", ["mova.vacuum.r9544a"]),
        Entry("Z70 Ultra Roller Complete", "z70-ultra-roller-complete", ["mova.vacuum.r5765h", "mova.vacuum.r5765k", "mova.vacuum.r5765p", "mova.vacuum.r5765q", "mova.vacuum.r5765u", "mova.vacuum.r5766h", "mova.vacuum.r5766k", "mova.vacuum.r5766q"])
    ]

    /// Deliberately no prefix matching: an unverified regional variant must keep the generic fallback.
    public static func lookup(model: String) -> Entry? {
        entries.first { $0.modelIDs.contains(model) }
    }

    public static func supportsGroupedCleaning(model: String, hasSelfWashBase: Bool) -> Bool {
        VerifiedMovaCapabilities.supportsGroupedCleaning(model: model, hasSelfWashBase: hasSelfWashBase)
    }
}
