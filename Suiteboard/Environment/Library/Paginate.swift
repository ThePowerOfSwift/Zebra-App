//
//  Paginate.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import ReactiveSwift
import Result
import Prelude

public func paginate(
    requestFirstPageWith requestFirstPage: Signal<String, NoError>,
    requestNextPageWhen  requestNextPage: Signal<(), NoError>,
    clearOnNewRequest: Bool,
    skipRepeats: Bool = true,
    valuesFromEnvelope: @escaping ((CompleteChannelEnvelope) -> [Block]),
    cursorFromEnvelope: @escaping ((CompleteChannelEnvelope) -> (String, Int)),
    requestFromParams: @escaping ((String) -> SignalProducer<CompleteChannelEnvelope, ErrorEnvelope>),
    requestFromCursor: @escaping ((String, Int) -> SignalProducer<CompleteChannelEnvelope, ErrorEnvelope>),
    concater: @escaping (([Block], [Block]) -> [Block]) = (+))
    ->
    (paginatedValues: Signal<[Block], NoError>,
    isLoading: Signal<Bool, NoError>,
    pageCount: Signal<Int, NoError>) {
        
        let cursor = MutableProperty<(String, Int)?>(nil)
        let isLoading = MutableProperty<Bool>(false)
        
        // Emits the last cursor when nextPage emits
//         let cursorOnNextPage = cursor.producer.skipNil().map { $0 + 1 }.sample(on: requestNextPage)
        
        let cursorOnNextPage = cursor.producer.skipNil().switchMap { (arg) -> SignalProducer<(String, Int), NoError> in
            let (slug, page) = arg
            let nextPage = page + 1
            return SignalProducer.init(value: (slug, nextPage))
            }.sample(on: requestNextPage)
        
        let paginatedValues = requestFirstPage
            .switchMap { requestParams in
                
                cursorOnNextPage.map(Either.right)
                    .prefix(value: .left(requestParams))
                    .switchMap { paramsOrCursor in
                        
                        paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
                            .ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(
                                starting: {
                                    isLoading.value = true
                            },
                                terminated: {
                                    isLoading.value = false
                            },
                                value: { env in
                                    cursor.value = cursorFromEnvelope(env)
                            })
                            .map(valuesFromEnvelope)
                            .demoteErrors()
                    }
                    .takeUntil { $0.isEmpty }
                    .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
                    .scan([], concater)
            }
            .skip(first: clearOnNewRequest ? 1 : 0)
        
        let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
            .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
            .filter { $0 > 0 }
        
        print("Page Count: \(pageCount)")
        
        return (
            (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
            isLoading.signal,
            pageCount
        )
}

public func paginateAllChannel(
    requestFirstPageWith requestFirstPage: Signal<(), NoError>,
    requestNextPageWhen  requestNextPage: Signal<(), NoError>,
    clearOnNewRequest: Bool,
    skipRepeats: Bool = true,
    valuesFromEnvelope: @escaping ((ListChannelsEnvelope) -> [ListChannel]),
    cursorFromEnvelope: @escaping ((ListChannelsEnvelope) -> (Int)),
    requestFromParams: @escaping (() -> SignalProducer<ListChannelsEnvelope, ErrorEnvelope>),
    requestFromCursor: @escaping ((Int) -> SignalProducer<ListChannelsEnvelope, ErrorEnvelope>),
    concater: @escaping (([ListChannel], [ListChannel]) -> [ListChannel]) = (+))
    ->
    (paginatedValues: Signal<[ListChannel], NoError>,
    isLoading: Signal<Bool, NoError>,
    pageCount: Signal<Int, NoError>) {
        
        let cursor = MutableProperty<Int?>(nil)
        let isLoading = MutableProperty<Bool>(false)
        
        // Emits the last cursor when nextPage emits
        //         let cursorOnNextPage = cursor.producer.skipNil().map { $0 + 1 }.sample(on: requestNextPage)
        
        let cursorOnNextPage = cursor.producer.skipNil().switchMap { arg -> SignalProducer<Int, NoError> in
            let nextPage = arg + 1
            return SignalProducer.init(value: nextPage)
            }.sample(on: requestNextPage)
        
        let paginatedValues = requestFirstPage
            .switchMap { requestParams in
                
                cursorOnNextPage.map(Either.right)
                    .prefix(value: .left(requestParams))
                    .switchMap { paramsOrCursor in
                        
                        paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
                            .ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(
                                starting: {
                                    isLoading.value = true
                            },
                                terminated: {
                                    isLoading.value = false
                            },
                                value: { env in
                                    cursor.value = cursorFromEnvelope(env)
                            })
                            .map(valuesFromEnvelope)
                            .demoteErrors()
                    }
                    .takeUntil { $0.isEmpty }
                    .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
                    .scan([], concater)
            }
            .skip(first: clearOnNewRequest ? 1 : 0)
        
        let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
            .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
            .filter { $0 > 0 }
        
        return (
            (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
            isLoading.signal,
            pageCount
        )
}

public func paginateSearchChannel(
    requestFirstPageWith requestFirstPage: Signal<String, NoError>,
    requestNextPageWhen  requestNextPage: Signal<(), NoError>,
    clearOnNewRequest: Bool,
    skipRepeats: Bool = true,
    valuesFromEnvelope: @escaping ((SearchChannelsEnvelope) -> [ListChannel]),
    cursorFromEnvelope: @escaping ((SearchChannelsEnvelope) -> (String, Int)),
    requestFromParams: @escaping ((String) -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope>),
    requestFromCursor: @escaping ((String, Int) -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope>),
    concater: @escaping (([ListChannel], [ListChannel]) -> [ListChannel]) = (+))
    ->
    (paginatedValues: Signal<[ListChannel], NoError>,
    isLoading: Signal<Bool, NoError>,
    pageCount: Signal<Int, NoError>) {
        
        let cursor = MutableProperty<(String, Int)?>(nil)
        let isLoading = MutableProperty<Bool>(false)
        
        // Emits the last cursor when nextPage emits
        //         let cursorOnNextPage = cursor.producer.skipNil().map { $0 + 1 }.sample(on: requestNextPage)
        
        let cursorOnNextPage = cursor.producer.skipNil().switchMap { (arg) -> SignalProducer<(String, Int), NoError> in
            let (slug, page) = arg
            let nextPage = page + 1
            return SignalProducer.init(value: (slug, nextPage))
            }.sample(on: requestNextPage)
        
        let paginatedValues = requestFirstPage
            .switchMap { requestParams in
                
                cursorOnNextPage.map(Either.right)
                    .prefix(value: .left(requestParams))
                    .switchMap { paramsOrCursor in
                        
                        paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
                            .ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(
                                starting: {
                                    isLoading.value = true
                            },
                                terminated: {
                                    isLoading.value = false
                            },
                                value: { env in
                                    cursor.value = cursorFromEnvelope(env)
                            })
                            .map(valuesFromEnvelope)
                            .demoteErrors()
                    }
                    .takeUntil { $0.isEmpty }
                    .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
                    .scan([], concater)
            }
            .skip(first: clearOnNewRequest ? 1 : 0)
        
        let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
            .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
            .filter { $0 > 0 }
        
        return (
            (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
            isLoading.signal,
            pageCount
        )
}

public func paginateSearchBlock(
    requestFirstPageWith requestFirstPage: Signal<String, NoError>,
    requestNextPageWhen  requestNextPage: Signal<(), NoError>,
    clearOnNewRequest: Bool,
    skipRepeats: Bool = true,
    valuesFromEnvelope: @escaping ((SearchBlocksEnvelope) -> [ListBlock]),
    cursorFromEnvelope: @escaping ((SearchBlocksEnvelope) -> (String, Int)),
    requestFromParams: @escaping ((String) -> SignalProducer<SearchBlocksEnvelope, ErrorEnvelope>),
    requestFromCursor: @escaping ((String, Int) -> SignalProducer<SearchBlocksEnvelope, ErrorEnvelope>),
    concater: @escaping (([ListBlock], [ListBlock]) -> [ListBlock]) = (+))
    ->
    (paginatedValues: Signal<[ListBlock], NoError>,
    isLoading: Signal<Bool, NoError>,
    pageCount: Signal<Int, NoError>) {
        
        let cursor = MutableProperty<(String, Int)?>(nil)
        let isLoading = MutableProperty<Bool>(false)
        
        // Emits the last cursor when nextPage emits
        //         let cursorOnNextPage = cursor.producer.skipNil().map { $0 + 1 }.sample(on: requestNextPage)
        
        let cursorOnNextPage = cursor.producer.skipNil().switchMap { (arg) -> SignalProducer<(String, Int), NoError> in
            let (slug, page) = arg
            let nextPage = page + 1
            return SignalProducer.init(value: (slug, nextPage))
            }.sample(on: requestNextPage)
        
        let paginatedValues = requestFirstPage
            .switchMap { requestParams in
                
                cursorOnNextPage.map(Either.right)
                    .prefix(value: .left(requestParams))
                    .switchMap { paramsOrCursor in
                        
                        paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
                            .ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(
                                starting: {
                                    isLoading.value = true
                            },
                                terminated: {
                                    isLoading.value = false
                            },
                                value: { env in
                                    cursor.value = cursorFromEnvelope(env)
                            })
                            .map(valuesFromEnvelope)
                            .demoteErrors()
                    }
                    .takeUntil { $0.isEmpty }
                    .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
                    .scan([], concater)
            }
            .skip(first: clearOnNewRequest ? 1 : 0)
        
        let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
            .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
            .filter { $0 > 0 }
        
        return (
            (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
            isLoading.signal,
            pageCount
        )
}

public func paginateSearchUsers(
    requestFirstPageWith requestFirstPage: Signal<String, NoError>,
    requestNextPageWhen  requestNextPage: Signal<(), NoError>,
    clearOnNewRequest: Bool,
    skipRepeats: Bool = true,
    valuesFromEnvelope: @escaping ((SearchUsersEnvelope) -> [ListUser]),
    cursorFromEnvelope: @escaping ((SearchUsersEnvelope) -> (String, Int)),
    requestFromParams: @escaping ((String) -> SignalProducer<SearchUsersEnvelope, ErrorEnvelope>),
    requestFromCursor: @escaping ((String, Int) -> SignalProducer<SearchUsersEnvelope, ErrorEnvelope>),
    concater: @escaping (([ListUser], [ListUser]) -> [ListUser]) = (+))
    ->
    (paginatedValues: Signal<[ListUser], NoError>,
    isLoading: Signal<Bool, NoError>,
    pageCount: Signal<Int, NoError>) {
        
        let cursor = MutableProperty<(String, Int)?>(nil)
        let isLoading = MutableProperty<Bool>(false)
        
        // Emits the last cursor when nextPage emits
        //         let cursorOnNextPage = cursor.producer.skipNil().map { $0 + 1 }.sample(on: requestNextPage)
        
        let cursorOnNextPage = cursor.producer.skipNil().switchMap { (arg) -> SignalProducer<(String, Int), NoError> in
            let (slug, page) = arg
            let nextPage = page + 1
            return SignalProducer.init(value: (slug, nextPage))
            }.sample(on: requestNextPage)
        
        let paginatedValues = requestFirstPage
            .switchMap { requestParams in
                
                cursorOnNextPage.map(Either.right)
                    .prefix(value: .left(requestParams))
                    .switchMap { paramsOrCursor in
                        
                        paramsOrCursor.ifLeft(requestFromParams, ifRight: requestFromCursor)
                            .ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(
                                starting: {
                                    isLoading.value = true
                            },
                                terminated: {
                                    isLoading.value = false
                            },
                                value: { env in
                                    cursor.value = cursorFromEnvelope(env)
                            })
                            .map(valuesFromEnvelope)
                            .demoteErrors()
                    }
                    .takeUntil { $0.isEmpty }
                    .mergeWith(clearOnNewRequest ? .init(value: []) : .empty)
                    .scan([], concater)
            }
            .skip(first: clearOnNewRequest ? 1 : 0)
        
        let pageCount = Signal.merge(paginatedValues, requestFirstPage.mapConst([]))
            .scan(0) { accum, values in values.isEmpty ? 0 : accum + 1 }
            .filter { $0 > 0 }
        
        return (
            (skipRepeats ? paginatedValues.skipRepeats(==) : paginatedValues),
            isLoading.signal,
            pageCount
        )
}
