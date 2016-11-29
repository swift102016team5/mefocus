//
//  UserStatisticViewController.swift
//  MeFocus
//
//  Created by Hao on 11/22/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit
import Foundation
import Charts

struct Sale {
    var month: String
    var value: Double
}

class SessionFormatter:NSObject,IAxisValueFormatter{
    
    var months:[String] = []
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return months[Int(value)]
        
    }
    
}

class DataGenerator {
    
    static var randomizedSale: Double {
        return Double(arc4random_uniform(10000) + 1) / 10
    }
    
    static func data() -> [Sale] {
        let months = ["Study","Work","Dinner","Coffee"]
        var sales = [Sale]()
        
        for month in months {
            let sale = Sale(month: month, value: randomizedSale)
            sales.append(sale)
        }
        
        return sales
    }
}

class UserStatisticViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get and prepare the data
        let sales = DataGenerator.data()
        
        // Initialize an array to store chart data entries (values; y axis)
        var salesEntries = [ChartDataEntry]()
        
        // Initialize an array to store months (labels; x axis)
        var salesMonths = [String]()
        
        var i:Double = 0
        for sale in sales {
            // Create single chart data entry and append it to the array
            let saleEntry = BarChartDataEntry(x:i, y: sale.value)
            salesEntries.append(saleEntry)
            
            // Append the month to the array
            salesMonths.append(sale.month)
            
            i += 1
        }
        // Create bar chart data set containing salesEntries
        let chartDataSet = BarChartDataSet(values: salesEntries, label: "Goal")
        let formatter = SessionFormatter()
        
        formatter.months = salesMonths
        chartDataSet.colors = [.flatOrange, .flatGreen, .flatBlue]
        
        // Set bar chart data to previously created data
        barChartView.data = BarChartData(dataSets: [chartDataSet])
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.leftAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.wordWrapEnabled = true
        barChartView.xAxis.setLabelCount(3, force: true)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.valueFormatter = formatter
        
        barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
