import SpriteKit

class Triangle: Symbol {

    override init() {
        super.init();
        
        attack_target["ff"] = true;
        attack_target["bl"] = true;
        attack_target["br"] = true;
        
        param_base = PARAM(hp:2, atk:3);
        param = param_base;

        image_name = Symbol.getSymbolName(.triangle);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}