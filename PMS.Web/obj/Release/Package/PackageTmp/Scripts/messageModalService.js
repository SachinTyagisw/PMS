angular.module('calendarApp').service('messageModalSvc', ['$modal', function ($modal) {
    return {
        'ShowMessage': function (message, scope) {
            scope.modalMessage = message;
            var modalInstance = $modal.open({
                size: 'sm',
                templateUrl: 'messageModalContent.html',
                backdrop: 'static',
                backdropClass: 'vendor-modal-backdrop',
                scope: scope
            });

            modalInstance.result.finally(function () {
                scope.modalMessage = null;
            });

            return modalInstance;
        },
        'CloseMessage': function (modalInstance) {
            if (modalInstance) modalInstance.dismiss();
        },

        // Confirmation Modal 
        'ShowConfirmationMessage': function (message, scope) {
            scope.modalMessage = message;
            scope.modalInstance = $modal.open({
                templateUrl: 'confirmationModalContent.html',
                backdrop: 'static',
                backdropClass: 'vendor-modal-backdrop',
                scope: scope,
                controller: function ($scope) {
                    $scope.yes = function () {
                        scope.modalInstance.close('yes');
                    };

                    $scope.no = function () {
                        scope.modalInstance.close('no');
                    };
                }
            });
            
            return scope.modalInstance;
        }
    };
}]);
