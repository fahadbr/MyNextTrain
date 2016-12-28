//: Playground - noun: a place where people can play

import RxSwift
import RxCocoa
import MyNextTrainCore

var disposeBag = DisposeBag()

let ob: Observable<[Int]> = Observable.create { (observer) -> Disposable in
    observer.onNext([])
    observer.onNext([1])
    Logger.debug("start MAD PROCESSING")
//    sleep(1000)
    Logger.debug("done MAD PROCESSING")
    observer.onNext([1, 3])
    observer.onCompleted()
    return Disposables.create()
}.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))

let subject = ReplaySubject<[Int]>.create(bufferSize: 1)

ob
    .debug("subject", trimOutput: false)
    .subscribe(subject)
//let variable = Variable<[Int]>([])
//
//ob.debug("binding").bindTo(variable).addDisposableTo(disposeBag)
//let subject = Observable.just(variable.value)

subject.asObservable()
    .debug("subscription")
    .subscribe({_ in }).addDisposableTo(disposeBag)

subject.asObservable()
    .debug("subscription 2")
    .subscribe { _ in }.addDisposableTo(disposeBag)
