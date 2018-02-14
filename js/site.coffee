---
---

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

outputRow = (row) ->
  if row[7]
    output = '<tr class="info">'
  else
    output = "<tr>"
  for col, i in row
    break if i == 7 # Skip the last column

    col = numeral(col).format('$0,0.00') if i >= 3 && i != 6

    if i in [1,2,4]
      klass = "hidden-sm hidden-xs"
    else
      klass = ""
    output += "<td class=\"#{klass}\">#{col}</td>"
  output += "</tr>\n"

  output

calculateGift = (totalAlumni, year) ->
  firstYearOfAlumni = 2006
  yearsOfAlumni = year - firstYearOfAlumni
  averageAlumniPerClass = totalAlumni / yearsOfAlumni
  alumniParticipation = parseInt($("#participation").val()) / 100.0
  averageParticipatingAlumniPerClass = averageAlumniPerClass * alumniParticipation

  giftAmounts = []
  giftAmounts.push(parseInt($("#giftTwentyPlus").val()))
  giftAmounts.push(parseInt($("#giftFifteenTillTwenty").val()))
  giftAmounts.push(parseInt($("#giftTenTillFifteen").val()))
  giftAmounts.push(parseInt($("#giftFiveTillTen").val()))
  giftAmounts.push(parseInt($("#giftTillFive").val()))

  gift = 0
  for cohort, i in [20, 15, 10, 5, 0]
    if cohort == 20
      cohortSize = Math.max(yearsOfAlumni - cohort, 0)
    else
      cohortSize = Math.min(Math.max(yearsOfAlumni - cohort, 0), 5)
    gift += cohortSize * averageParticipatingAlumniPerClass * giftAmounts[i]

  gift

calculate = ->
  table = [
    [2015, 320, 594, 81811, 0, 0, 0, true],
    [2016, 320, 674, 195137, 0, 75, 64, true]
    [2017, 320, 754, 263420, 25327, 75, 68, true]
  ]
  # Remember to update both of these values when adding a new row above.
  startYear = 2018
  previous = table[2] # Increment this value when there's a new row

  studentsPerClass = parseInt($("#studentsPerClass").val())
  futureYears = parseInt($("#futureYears").val())
  endowmentRate = parseInt($("#endowmentIncome").val()) / 100.0

  for year in [startYear..(startYear+futureYears)]
    previousTotalAlumni = previous[2]
    pastEndowment = previous[3]

    totalStudents = studentsPerClass * 4
    totalAlumni = previousTotalAlumni + studentsPerClass

    gift = calculateGift(totalAlumni, year)
    currentEndowment = pastEndowment + gift
    if currentEndowment > 125000
      currentIncome = currentEndowment * endowmentRate
    else
      currentIncome = 0
    distribution = currentIncome / studentsPerClass

    current = [year, totalStudents, totalAlumni, currentEndowment, currentIncome, distribution, studentsPerClass, false]
    previous = current
    table.push current

  output = ""
  for row in table
    output += outputRow(row)

  $("#model tbody").html(output)

$ ->
  $("#recalculate").click ->
    calculate()
  calculate()
