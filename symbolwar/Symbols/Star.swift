import SpriteKit

class Star: Symbol {
    
    override init() {
        super.init();
        
        attack_target["ff"] = true;
        attack_target["fl"] = true;
        attack_target["fr"] = true;
        attack_target["bl"] = true;
        attack_target["br"] = true;
        
        param_base = PARAM(hp:2, atk:5);
        param = param_base;

        image_name = Symbol.getSymbolName(.star);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}