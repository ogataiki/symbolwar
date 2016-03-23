import SpriteKit

class Symbol {
    
    enum SYMBOL_TYPE {
        case triangle, square, star, circle
    }
    var type = SYMBOL_TYPE.triangle;
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
    
    let param_total = 13;
    
    var attack_target: [String : Bool] = [
        "fl" : false, "ff" : false, "fr" : false,
        "bl" : false, "bb" : false, "br" : false
    ];
    var attack_target_list: [String] = [];
    
    var counter = false;
    
    struct PARAM {
        var hp: Int;
        var atk: Int;
    }
    var param_base = PARAM(hp:1, atk:1);
    var param = PARAM(hp:1, atk:1);
    
    func initParam() {
        for s in attack_target_list {
            attack_target[s] = true;
        }
        var p = PARAM(hp:param_total, atk:param_total);
        p.hp -= attack_target_list.count;
        p.hp = counter ? p.hp - 3 : p.hp;
        p.atk = p.atk - (attack_target_list.count * 2);
        p.atk = counter ? 0 : p.atk;
        param_base = p;
        param = param_base;
        
        label_hp.position = CGPoint(x:0, y:sprite.size.height*0.15);
        label_atk.position = CGPoint(x:0, y:0-sprite.size.height*0.15);
        label_hp.fontSize = 8.0;
        label_atk.fontSize = 8.0;
        label_hp.fontName = "HelveticaNeue-Bold";
        label_atk.fontName = "HelveticaNeue-Bold";
        label_hp.fontColor = UIColor.blueColor();
        label_atk.fontColor = UIColor.blueColor();
        label_hp.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center;
        label_hp.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        label_atk.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center;
        label_atk.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        
        sprite.addChild(label_hp);
        sprite.addChild(label_atk);
    }
    
    static let size: CGFloat = UIScreen.mainScreen().bounds.size.height > 640 ? 64 : 32;
    
    var image_name = "";
    var sprite = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: Symbol.size, height: Symbol.size));
    
    var label_hp = SKLabelNode(text: "");
    var label_atk = SKLabelNode(text: "");
    func updateParamSprite() {
        label_hp.text = "HP:\(param.hp)";
        label_atk.text = "ATK:\(param.atk)";
        if param.hp <= 0 {
            label_hp.fontColor = UIColor.redColor();
        }
    }
    
    var player = false;
    func setPlayerMode() {
        player = true;
    }
    var enemy = false;
    func setEnemyMode() {
        enemy = true;
        sprite.yScale = -1;
        // パラメータ表示はプレイヤーから正しく見えるように
        for child in sprite.children {
            child.yScale = -1;
        }
        sprite.blendMode = SKBlendMode.Subtract;
    }
    
    var deploy_turn: Int = 0;
    var deploy_index: Int = 0;
    
    var rc: (r: Int, c: Int) = (0, 0);
}