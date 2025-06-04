import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupButtons()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "startBackgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
    }
    
    private func setupButtons() {
        let playButton = SKSpriteNode(imageNamed: "playButtonImage")
        playButton.name = "playButton"
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        playButton.zPosition = 3
        addChild(playButton)
        
        let startButton = SKSpriteNode(imageNamed: "startButtonImage")
        startButton.name = "startButton"
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startButton.zPosition = 2
        addChild(startButton)
        
        let aboutButton = SKSpriteNode(imageNamed: "settingsButtonImage")
        aboutButton.name = "settingsButton"
        aboutButton.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        aboutButton.zPosition = 1
        addChild(aboutButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1))
        } else if touchedNode.name == "startButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1))        }
    }
    
}
