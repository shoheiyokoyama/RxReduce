//
//  MovieListViewController.swift
//  RxReduceDemo
//
//  Created by Thibault Wittemberg on 18-06-04.
//  Copyright © 2018 Wittemberg, Thibault. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import RxReduce

class MovieListViewController: UITableViewController, StoryboardBased, Injectable {

    typealias InjectionContainer = HasStore & HasNetworkService

    let disposeBag = DisposeBag()

    var injectionContainer: InjectionContainer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        let loadMovieAction: Observable<Action> = self.injectionContainer.networkService
            .fetch(withRoute: Routes.discoverMovie)
            .asObservable()
            .map { $0.movies }
            .map { LoadMovieListAction.init(movies: $0) }
            .startWith(FetchMovieListAction())

        let movieListState = self.injectionContainer.store.state { (appState) -> MovieListState in
            return appState.movieListState
        }

        movieListState.drive(onNext: { (movieListState) in
            switch movieListState {
            case .empty:
                print ("EMPTY")
            case .loading:
                print ("LOADING")
            case .loaded(let movies):
                print ("LOADED \(movies)")
            }
        }).disposed(by: self.disposeBag)

        self.injectionContainer.store.dispatch(action: loadMovieAction)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
