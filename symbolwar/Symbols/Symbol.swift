import SpriteKit

class Symbol {
    
    enum SYMBOL_TYPE {
        case triangle, square, star, circle
    }
    static func getSymbolName(type: SYMBOL_TYPE) -> String {
        switch type {
        case .triangle: return "Triangle";
        case .square: return "Square";
        case .star: return "Star";
        case .circle: return "Circle";
        }
    }
    
    static func createSymbol(name: String) -> Symbol? {
        switch name {
        case Symbol.getSymbolName(.triangle): return Triangle();
        case Symbol.getSymbolName(.square): return Square();
        case Symbol.getSymbolName(.star): return Star();
        case Symbol.getSymbolName(.circle): return Circle();
        default: return nil;
        }
    }
    
    var attack_target: [String : Bool] = [
        "fl" : false, "ff" : false, "fr" : false,
        "bl" : false, "bb" : false, "br" : false
    ];
    
    var counter = false;
    
    struct PARAM {
        var hp = 2;
        var atk = 1;
    }
    var param_base = PARAM();
    var param = PARAM();
    
    static let size: CGFloat = UIScreen.mainScreen().bounds.size.height > 640 ? 64 : 32;
    
    var image_name = "";
    var sprite = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: Symbol.size, height: Symbol.size));
    
    var player = false;
    func setPlayerMode() {
        player = true;
    }
    var enemy = false;
    func setEnemyMode() {
        enemy = true;
        sprite.yScale = -1;
        sprite.blendMode = SKBlendMode.Subtract;
    }
    
    var deploy_turn: Int = 0;
    var deploy_index: Int = 0;
    
    var rc: (r: Int, c: Int) = (0, 0);
}