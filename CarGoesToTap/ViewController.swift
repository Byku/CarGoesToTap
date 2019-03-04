import UIKit

struct Constants {
    static let carWidth: CGFloat = 50
    static let carLength: CGFloat = 100
    static let turningRadius: CGFloat = 70
    static let colors: [UIColor] = [.yellow, .red, .blue, .black, .gray, .green, .orange]
}

class ViewController: UIViewController {
    private var car: Car!
    private var map: UIView!
    private var gesture: UITapGestureRecognizer!
    
    private var tapPosition: (x: CGFloat, y: CGFloat) = (0, 0) {
        didSet {
            map.removeGestureRecognizer(gesture)
            carMoving()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let's create square "map"
        let mapWidth = max(view.frame.height, view.frame.width)
        map = UIView(frame: CGRect(x: 0, y: 0, width: mapWidth, height: mapWidth))
        view.addSubview(map)
        
        // let's create car and put it on our square map
        let carXPosition = (view.frame.width - Constants.carWidth) * 0.5
        let carYPosition = view.frame.height - Constants.carLength
        car = Car(at: Position(x: carXPosition, y: carYPosition), orientation: .top)
        car.backgroundColor = .yellow
        map.addSubview(car)
        
        gesture = UITapGestureRecognizer(target: self, action:  #selector (self.viewTapped (_:)))
        map.addGestureRecognizer(gesture)
    }
}

private extension ViewController {
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: car)
            if car.point(inside: point, with: nil) {
                car.backgroundColor = Constants.colors[Int.random(in: 0..<7)]
            } else {
                tapPosition = (sender.location(in: map).x, sender.location(in: map).y)
            }
        }
    }
    
    func carMoving() {
        guard let moveStep = car.makeDecisionToNextStep(finishPoint: tapPosition) else {
            moveFinished()
            return
        }
        switch moveStep {
        case let .move(distance):
            car.move(for: distance) { [unowned self] in
                self.carMoving()
            }
        case let .turn(turnDirection):
            car.turn(to: turnDirection) {
                self.carMoving()
            }
        }
    }
    
    func moveFinished() {
        map.addGestureRecognizer(gesture)
    }
}

extension ViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        map.bounds.origin = CGPoint(x: 0, y: 0)
        
        // move map if the car is out of screen
        if car.position.x > size.width {
            map.bounds.origin.x += car.position.x - size.width + Constants.carLength
        }
        if car.position.y > size.height {
            map.bounds.origin.y += car.position.y - size.height + Constants.carLength
        }
    }
}
