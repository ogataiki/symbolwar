import SpriteKit

class Star: Symbol {
    
    override init() {
        super.init();
        
        type = .star;
        image_name = Symbol.getSymbolName(type);
        sprite = SKSpriteNode(imageNamed: image_name);
        
        attack_target_list = ["ff", "fl", "fr", "bl", "br"];
        initParam();
        updateParamSprite();
    }
}