import SpriteKit

class Square: Symbol {
    
    override init() {
        super.init();
        
        attack_target["fl"] = true;
        attack_target["fr"] = true;
        attack_target["bl"] = true;
        attack_target["br"] = true;
        
        param_base = PARAM(hp:2, atk:4);
        param = param_base;

        image_name = Symbol.getSymbolName(.square);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}