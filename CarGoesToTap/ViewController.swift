import UIKit

struct Constants {
    static let carWidth: CGFloat = 50
    static let carLength: CGFloat = 100
    static let turningRadius: CGFloat = 70
}

enum carOrientation {
    case top
    case right
    case left
    case down
}

enum TurnType {
    case right
    case left
}

enum MovingType {
    case move(CGFloat)
    case turn(TurnType)
}

struct Position {
    var x: CGFloat
    var y: CGFloat
}

struct Car {
    var position: Position
    var orientation: carOrientation
    
    var movingDirection: CGFloat {
        switch self.orientation {
        case .down, .right:
            return 1
        case .top, .left:
            return -1
        }
    }
}

class ViewController: UIViewController {
    private var myView: UIView!
    private var car: Car!
    
    private var tapPosition: (x: CGFloat, y: CGFloat)? {
        didSet {
            view.layer.removeAllAnimations()
            carMoving()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let carXPosition = (view.frame.width - Constants.carWidth) * 0.5
        let carYPosition = view.frame.height - Constants.carLength
        car = Car(position: Position(x: carXPosition, y: carYPosition), orientation: .top)
        myView = UIView(frame: CGRect(x: car.position.x,
                                      y: car.position.y,
                                      width: Constants.carWidth,
                                      height: Constants.carLength))
        myView.backgroundColor = .yellow
        view.addSubview(myView)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.viewTapped (_:)))
        view.addGestureRecognizer(gesture)
    }
}

private extension ViewController {
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            tapPosition = (sender.location(in: view).x, sender.location(in: view).y)
        }
    }
    
    func carMoving() {
        guard let moveStep = makeDecisionToNextStep(finishPoint: tapPosition!) else {
            moveFinished()
            return
        }
        switch moveStep {
        case let .move(distance):
            move(for: distance)
        case let .turn(turnDirection):
            turn(to: turnDirection)
        }
    }
    
    func makeDecisionToNextStep(finishPoint destination: (x: CGFloat, y: CGFloat)) -> MovingType? {
        // проверяем текущую и конечную позиции
        let currX = myView.frame.midX
        let currY = myView.frame.midY
        let deltaX = destination.x - currX
        let deltaY = destination.y - currY
        let minMove = Constants.carLength * 0.5
        if abs(deltaX) <= Constants.turningRadius && abs(deltaY) <= Constants.turningRadius {
            return nil
        }
        
        // проверяем, куда направлена пипка чтобы подъехать ближе или повернуться в нужную сторону
        switch car.orientation {
        case .top where deltaY < -minMove,
             .down where deltaY > minMove:
            return .move(abs(deltaY) - minMove)
        case .left where deltaX < -minMove,
             .right where deltaX > minMove:
            return .move(abs(deltaX) - minMove)
        case .top where deltaY >= -minMove:
            return deltaX < 0 ? .turn(.left) : .turn(.right)
        case .down where deltaY <= minMove:
            return deltaX < 0 ? .turn(.right) : .turn(.left)
        case .left where deltaX >= -minMove:
            return deltaY < 0 ? .turn(.right) : .turn(.left)
        case .right where deltaX <= minMove:
            return deltaY < 0 ? .turn(.left) : .turn(.right)
        default:
            return nil
        }
    }
    
    func move(for distance: CGFloat) {
        let multiplier = car.movingDirection
        
        UIView.animate(withDuration: 0.7, animations: { [unowned self] in
            switch self.car.orientation {
            case .top, .down:
                self.myView.frame.origin.y += multiplier * distance
            case .left, .right:
                self.myView.frame.origin.x += multiplier * distance
            }
        }) { [unowned self] _ in
            self.carMoving()
        }
    }
    
    func turn(to turnDirection: TurnType) {
        var turnMovingY: CGFloat
        var turnMovingX: CGFloat
        var angle: CGFloat
        
        switch (car.orientation, turnDirection) {
        case (.top, .right):
            turnMovingY = -Constants.turningRadius
            turnMovingX = Constants.turningRadius
            angle = .pi / 2
            car.orientation = .right
        case (.right, .right):
            turnMovingY = Constants.turningRadius
            turnMovingX = Constants.turningRadius
            angle = .pi / 2
            car.orientation = .down
        case (.down, .right):
            turnMovingY = Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            angle = .pi / 2
            car.orientation = .left
        case (.left, .right):
            turnMovingY = -Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            angle = .pi / 2
            car.orientation = .top
        case (.top, .left):
            turnMovingY = -Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            angle = -.pi / 2
            car.orientation = .left
        case (.right, .left):
            turnMovingY = -Constants.turningRadius
            turnMovingX = Constants.turningRadius
            angle = -.pi / 2
            car.orientation = .top
        case (.down, .left):
            turnMovingY = Constants.turningRadius
            turnMovingX = Constants.turningRadius
            angle = -.pi / 2
            car.orientation = .right
        case (.left, .left):
            turnMovingY = Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            angle = -.pi / 2
            car.orientation = .down
        }
        
        UIView.animate(withDuration: 0.5, animations: { [unowned self] in
            self.myView.frame.origin.y += turnMovingY
            self.myView.frame.origin.x += turnMovingX
            self.myView.transform = self.myView.transform.rotated(by: angle)
            self.myView.layoutIfNeeded()
        }) { [unowned self] _ in
            self.carMoving()
        }
    }
    
    func moveFinished() {
        print("I'm here!")
    }
}
