import SpriteKit

class Square: Symbol {
    
    override init() {
        super.init();
        
        type = .square;
        image_name = Symbol.getSymbolName(type);
        sprite = SKSpriteNode(imageNamed: image_name);
        
        attack_target_list = ["fl", "fr", "bl", "br"];
        initParam();
        updateParamSprite();
    }
}