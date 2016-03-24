import SpriteKit

final class SymbolMgr
{
    private init() {
        
    }
    
    static let sharedInstance = SymbolMgr()

    var symbols: [Int : Symbol] = [:];
    var uniq_id_counter: Int = 0;
    var trashbox_id: [Int] = [];
    func entrySymbol(s: Symbol) -> Int {
        var entry_id = 0;
        if trashbox_id.count > 0 {
            // idを再利用
            entry_id = trashbox_id[0];
            trashbox_id.removeAtIndex(0);
        }
        else {
            // idを新規作成
            entry_id = uniq_id_counter;
            uniq_id_counter += 1;
        }
        s.unique = entry_id;
        symbols[entry_id] = s;
        return entry_id;
    }
    func getSymbol(uniq: Int) -> (result: Bool, symbol: Symbol?) {
        if let symbol = symbols[uniq] {
            return (true, symbol);
        }
        return (false, nil);
    }
    func trashSymbol(s: Symbol) {
        trashbox_id.append(s.unique);
        symbols.removeValueForKey(s.unique);
    }
    func clearSymbols() {
        symbols = [:];
        uniq_id_counter = 0;
        trashbox_id = [];
    }
}

