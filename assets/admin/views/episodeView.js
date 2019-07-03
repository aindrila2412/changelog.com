import ApexCharts from "apexcharts";
import Clipboard from "clipboard";
import SearchWidget from "components/searchWidget";
import FilterWidget from "components/filterWidget";
import CalendarField from "components/calendarField";
import Modal from "components/modal";

export default class EpisodeView {
  constructor() {
    this.chartOptions = {
      chart: {
        type: "line",
        height: 400
      },
      yaxis: {
         decimalsInFloat: 0,
         labels: {
          formatter: function(val) {
            return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
           }
         }
      }
    }
  }

  index() {
    new FilterWidget();

    let scheduled = $(".ui.calendar").data("scheduled").map((string) => {
      let date = new Date(string);
      return date.toDateString();
    });

    $(".ui.calendar").calendar({
      type: "date",
      isDisabled: function (date, mode) {
        for (var i = scheduled.length - 1; i >= 0; i--) {
          if (scheduled[i] == date.toDateString()) {
            return true;
          }
        }

        return false;
      }
    });

    let chartOptions = this.chartOptions;

    $(".launch-chart").each(function(index) {
      let data = $(this).data("chart");

      let options = $.extend(chartOptions, {
        title: {
          text: data.title
        },
        series: data.series,
        xaxis: {
          categories: data.categories
        }
      });

      let chart = new ApexCharts(this, options);
      chart.render();
    });
  }

  show() {
    let clipboard = new Clipboard(".clipboard.button", {
      target: function(trigger) {
        return trigger.previousElementSibling;
      }
    });

    clipboard.on("success", function(e) {
      $(e.trigger).popup({variation: "inverted", content: "Copied!"}).popup("show");
      e.clearSelection();
    });

    clipboard.on("error", function(e) {
      console.log(e);
    });

    let chartOptions = this.chartOptions;

    $(".chart").each(function(index) {
      let data = $(this).data("chart");

      let options = $.extend(chartOptions, {
        title: {
          text: data.title
        },
        series: data.series,
        xaxis: {
          categories: data.categories
        }
      });

      let chart = new ApexCharts(this, options);
      chart.render();
    });
  }

  new() {
    new SearchWidget("person", "episode", "episode_hosts");
    new SearchWidget("person", "episode", "episode_guests");
    new SearchWidget("sponsor", "episode", "episode_sponsors");
    new SearchWidget("topic", "episode", "episode_topics");
    new CalendarField(".ui.calendar");
    new Modal(".js-title-guide-modal", ".title-guide.modal");
    new Modal(".js-subtitle-guide-modal", ".subtitle-guide.modal");
  }

  edit() {
    this.new();

    new Modal(".js-publish-modal", ".publish.modal");

    let newsInput = $("input[name=news]");
    let thanksInput = $("input[name=thanks]");

    newsInput.on("change", function() {
      if (newsInput.is(":checked")) {
        thanksInput.closest(".checkbox").checkbox("set enabled");
      } else {
        thanksInput.closest(".checkbox").checkbox("set disabled").checkbox("uncheck");
      }
    });
  }
}
