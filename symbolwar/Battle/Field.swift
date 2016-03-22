import SpriteKit

class Field {
    
    static let size: CGFloat = UIScreen.mainScreen().bounds.size.height > 640 ? 64 : 32;

    var row: Int;
    var column: Int;
    
    var sprite: SKSpriteNode = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: Field.size, height: Field.size));
    
    var player_field = false;
    var enemy_field = false;
    
    var symbol: Symbol? = nil;
    
    init(r: Int, c: Int) {
        self.row = r;
        self.column = c;
    }
    
    func setPlayerField(val: Int) {
        player_field = true;
        sprite.color = UIColor.greenColor();
        sprite.name = "player_field\(val)";
    }
    func setEnemyField() {
        enemy_field = true;
        sprite.color = UIColor.orangeColor();
    }
}
