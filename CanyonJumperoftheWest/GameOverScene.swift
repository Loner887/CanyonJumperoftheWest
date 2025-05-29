import SpriteKit

class GameOverScene: SKScene {
    
    var backgroundImage: CGImage?
    var coinCount: Int = 0
    var chestCount: Int = 0

    override func didMove(to view: SKView) {
        if let image = backgroundImage {
            let texture = SKTexture(cgImage: image)
            let bg = SKSpriteNode(texture: texture)
            bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
            bg.size = size
            bg.zPosition = -1
            addChild(bg)
        }
        setupBackground()
        setupUi()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "overBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        background.size = size
        addChild(background)
    }
    
    private func setupUi() {
        let coin = SKLabelNode(text: "\(coinCount)")
        coin.fontName = "Avenir-Black"
        coin.fontSize = 48
        coin.fontColor = .black
        coin.position = CGPoint(x: size.width * 0.25, y: size.height * 0.45)
        coin.zPosition = 2
        addChild(coin)
        
        let chest = SKLabelNode(text: "\(chestCount)")
        chest.fontName = "Avenir-Black"
        chest.fontSize = 48
        chest.fontColor = .black
        chest.position = CGPoint(x: size.width * 0.65, y: size.height * 0.45)
        chest.zPosition = 2
        addChild(chest)

        let button = SKSpriteNode(imageNamed: "startButtonImage")
        button.name = "menuButton"
        button.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        button.zPosition = 2
        addChild(button)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.atPoint(location)

            if node.name == "menuButton" {
                let startScene = StartScene(size: size)
                let transition = SKTransition.fade(withDuration: 1.0)
                view?.presentScene(startScene, transition: transition)
            }
        }
    }
}
